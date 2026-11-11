---
title: "Your WebSocket Outlived Your Logout"
date: 2026-11-09 17:00:00 +0200
categories: [API Security, Session Management]
tags: [websocket, socketio, engineio, logout, session, authentication, revocation, pentest]
toc: true
---

![Your WebSocket outlived your logout: the HTTP side shows the token revoked, but the live WebSocket is still connected and still receiving notifications, room updates and messages until the token expires. The fix is to make logout, refresh and token revocation close every live socket for that session](/assets/img/websocket-outlived-logout.webp)

## 𓂀 You clicked "log out". Did everything log out?

You click **Log out**. The app says you're signed out. The server revokes your token. Every REST call with that token now returns `401`. Looks done.

But the real-time connection you opened an hour ago is still open, still sitting in your room, and still receiving your notifications.

That's the bug. Not a broken logout endpoint. A logout that only ever reached **one channel**.

## 𓅃 Why it happens

A typical real-time gateway authenticates a socket **once**, at connect time. After that, the connection is just... open. The question is what ends it.

In a lot of designs the answer is only this: *a timer*. When the socket connects, the server reads the token's `exp` claim and schedules a disconnect for that moment. That's the entire lifecycle.

Notice what's missing:

- **Logout** revokes the token in the HTTP layer (blacklist, `jti` deny-list, session row deleted) but never tells the gateway.
- **Token refresh** issues a new token but nobody closes the sockets that were opened with the old one.
- **Account disable / password change** does the same: the HTTP side reacts, the socket side never hears about it.

The REST side and the socket side keep **separate notions of "this session is valid"**, and only one of them is wired to the revoke button.

## 𓂀 Why it matters

Logout is not a neutral action. It's what a victim does when they think something is wrong: a lost phone, a shared computer, a suspicious login.

If a socket survives logout, whoever already holds that connection keeps receiving that user's live events, silently, until the token's natural expiry. The user did the right thing and it didn't cut the cord.

To be precise about the impact: this is **receive-only**. The attacker is not acting as the user. They are listening to what the user's room receives (notifications, status updates, messages). That's still a real confidentiality problem, and it's exactly the window the user thought they had just closed.

Related: CWE-613 (Insufficient Session Expiration) and OWASP ASVS section 3.3 (session termination).

## 𓅃 How to test it

You don't need a special WebSocket client. Socket.IO runs on top of **Engine.IO**, and Engine.IO starts life as plain HTTP long-polling. So you can drive the whole test with `curl` or a few lines of Python, and see exactly what the server does at each step.

The idea in four steps:

1. **Connect** and record the session id (`sid`).
2. **Authenticate the namespace** with a valid token, and confirm you are receiving events.
3. **Log out on the normal HTTP side.** Confirm the REST API now rejects that token.
4. **Poll the same `sid` again.** If the server still answers with valid packets (pings, events) instead of closing the session, revocation never reached the socket.

A minimal sketch (Engine.IO v4, generic placeholder host):

```python
import requests, json

BASE = "https://api.example.test/socket.io/"
Q    = {"EIO": "4", "transport": "polling"}

# 1) open an Engine.IO session
r   = requests.get(BASE, params=Q)
sid = json.loads(r.text[1:])["sid"]          # body looks like: 0{"sid":"...",...}
Q["sid"] = sid

# 2) connect the namespace with a valid token (Socket.IO CONNECT packet)
requests.post(BASE, params=Q,
              data='40/events,{"token":"<valid token>"}')
print(requests.get(BASE, params=Q).text)     # expect a CONNECT ack with your socket id

# 3) log out through the normal HTTP API (not shown), then confirm
#    the REST side rejects the old token with 401

# 4) poll the SAME sid again
print(requests.get(BASE, params=Q).text)
#   closed / "invalid sid"  -> good, the socket was torn down
#   pings or events         -> the socket outlived the logout
```

Two practical notes:

- Remember to answer the server's ping (`2`) with a pong (`3`) on the POST side, or the socket will time out on its own and you'll misread it as a pass.
- Run it for longer than the ping interval, and also test the **refresh** path, not only logout. Many gateways handle neither.

If the target only accepts WebSocket and blocks polling, the same test works with any WebSocket client: connect, log out over HTTP, then check whether the same connection is still delivering events.

## 𓂀 The fix

Make **revocation reach every channel**, and make it **fail closed**:

- On **logout, refresh, password change and account disable**, publish a "session revoked" event.
- The gateway **subscribes to that event** and disconnects every live socket tied to that session (index sockets by user id and session/`jti`, so you can find them).
- Keep the `exp` timer as a backstop, not as the only control.
- If the gateway can't confirm the session is still valid, **close the socket**. Never default to leaving it open.

A cheap extra layer: re-validate the session on a periodic heartbeat, so a missed revocation event heals itself within one interval.

## 𓅃 The takeaway

Logout is not one thing. It's *"end every way this session can still see data."* An HTTP `401` only proves one of them.

When you test logout, test the sockets too.
