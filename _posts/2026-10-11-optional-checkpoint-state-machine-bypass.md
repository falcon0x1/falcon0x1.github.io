---
title: "The Optional Checkpoint: Skipping a Mandatory Step in Multi-Step Flows"
date: 2026-10-11 10:00:00 +0200
categories: [Web Security, Business Logic]
tags: [business-logic, state-machine, api-security, authorization, workflow-bypass]
toc: true
---

## Okay so what even is a "state-machine bypass"?

Loads of apps have a flow that's supposed to go in order. Think of any "someone does a job and proves it" workflow:

> **start** the job → **upload proof** (a photo, a signature, a scan) → **mark complete** → money moves.

The app shows these as three screens, one after another. You literally can't tap "Complete" until you've done the photo step — the button is greyed out.

That ordering is a **state machine**: the thing is allowed to move `started → verified → completed`, and *not* allowed to jump `started → completed`. The bug is simple to say and easy to miss: **the server never actually enforces the order.** Only the app does.

---

## The setup (this is the important part)

Here's the mental model of what's usually running on the backend:

```
PATCH /job/start      -> state = "started"
PATCH /job/photos     -> state = "verified"   (the evidence step)
PATCH /job/complete   -> if state == "verified": pay out
                         // but what if it's only "started"?
```

The developer *assumes* `complete` is only ever called after `photos`, because that's the only path the app offers. So they write `complete` to just... finalize. No check that the evidence step actually happened.

The app is a suggestion. The API is the real thing. If I can call `complete` straight after `start`, I skip the checkpoint entirely.

---

## The attack

1. `PATCH /job/start` — totally legit, I'm allowed to start.
2. **Skip `/job/photos` completely.** Never call it.
3. `PATCH /job/complete` — and the server says `200 OK, completed`.

That's it. The job is now "done", the customer is billed, the payout fires — and there is **no photo, no signature, no proof of anything** attached to it. The one record that was supposed to make fraud detectable is simply absent, because the step that creates it was never required.

In a field-service / delivery / fuel / inspection context, that's a corrupt operator's dream: mark jobs complete, collect, and leave zero evidence of what was (or wasn't) actually delivered. Disputes become un-investigatable because there's nothing to investigate with.

![State-machine bypass: the attacker skips the verification checkpoint]({{ '/assets/img/state-machine-bypass.png' | relative_url }})
_Intended flow: start → verify → complete. The server never checks the order, so calling `/complete` straight after `/start` finalizes the job with the proof step skipped._

---

## Why testers miss it (and how I nearly did)

Two traps, both about trusting the wrong thing:

- **"The UI won't let me, so the server won't either."** You open the app, the Complete button is disabled until you add a photo, and your brain files it as "enforced." It isn't — the gate is client-side. Always re-fire the final call directly, out of order, from your own client.
- **"I checked and the step is required."** Earlier in the same flow I convinced myself a value wasn't even reachable, based on a *truncated* response dump that cut off one field too early. A negative claim ("this can't be done", "that field isn't there") needs the same proof as a positive one: print the **full** response of a **fresh** object, and test the exact out-of-order call. Don't conclude from a half-read body.

The honest framing also matters for severity. In the flow I looked at, the money amount itself was cryptographically bound to an earlier token, so the operator *couldn't* change the price — tampering it returned "data does not match." So this isn't "steal arbitrary money." It's an **evidence / accountability** bypass: the integrity control (proof-of-work) is optional. Name the bug for what it actually is (think CWE-840, business logic), and credit the controls that *did* hold. An over-claimed "Critical: fuel theft" gets you argued with; a precise "the verification step is not enforced server-side" gets fixed.

---

## How I'd test for it

1. Walk the flow once normally. Capture every request (Burp/ZAP history). Note the exact order and the state value in each response.
2. Identify the "checkpoint" step — the one that produces proof/verification (photos, OTP, signature, approval).
3. Start a fresh object, then **jump straight to the final step**, skipping the checkpoint. Does `complete` succeed?
4. Try the other orderings too: complete twice, complete before start, cancel after complete. State machines leak in more than one place.
5. Read the *full* response at each stage — don't let a truncated log decide the verdict.
6. Confirm the real-world effect: did the record finalize with the checkpoint data genuinely missing?

---

## The fix (for devs reading this)

- **Enforce transitions on the server, every time.** `complete` must reject unless the object actually passed through the required state (e.g. `verified`). A disabled button is UX, not a control.
- **Make the evidence step a hard precondition**, not an assumed one — check that the proof exists before finalizing/paying.
- Treat the client as hostile: any step the UI enforces, assume an attacker will call the API without it.

---

## TL;DR

If a multi-step flow has a "mandatory" checkpoint that's only enforced by the app, try calling the final step straight after the first one. If the server finalizes with the checkpoint skipped, you've got a state-machine bypass. Score it by what's actually lost — often it's the *evidence*, not the money — and say so precisely.

---

**Happy Hunting,**
*Falcon0x1*
