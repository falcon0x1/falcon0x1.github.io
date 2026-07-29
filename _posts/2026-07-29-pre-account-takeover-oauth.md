---
title: "Pre-Account Takeover via OAuth: The Bug That Waits For You"
date: 2026-07-29 10:00:00 +0200
categories: [Web Security, Authentication]
tags: [oauth, account-takeover, pre-ato, authentication, web-security]
toc: true
---

## Okay so what even is "Pre" Account Takeover?

Normal account takeover = attacker steals YOUR existing account.

Pre-Account Takeover = attacker creates the trap **before you even sign up**. You register later, the app quietly hands your new account to them, and you never know it happened. That "pre" is what makes it sneaky — the attack happens before the victim exists on the site.

I ran into this while messing around with an app that supported both:
- normal email + password signup
- "Continue with Google" (OAuth)

And that combo is exactly the recipe for this bug.

---

## The setup (this is the important part)

Most sites link your account to your **email**, not to "Google" or "Facebook" as a person. So somewhere in the backend there's basically:

```
if email_exists_in_db(email):
    link_this_oauth_login_to_that_account
else:
    create_new_account(email)
```

Looks harmless right? Here's the attack:

1. Attacker knows victim's email: `victim@gmail.com` (from a leak, LinkedIn, wherever).
2. Attacker signs up on the target site using **email + password** with `victim@gmail.com`. Account created, unverified, sitting there.
3. Victim never sees this. They don't check that inbox often, or the app doesn't even force email verification before letting the account "exist."
4. Later, victim clicks "Sign in with Google" on the same site, using their real `victim@gmail.com` Google account.
5. The app sees the email already exists in the DB and just... links the Google login to that existing account. The one the attacker made.
6. Now both the attacker's password AND the victim's Google login open the same account. Attacker just waits and logs in with the password they set.

No verification email was ever confirmed by the victim, but the app trusted "same email = same person." That assumption is the whole bug.

---

## Why this actually works so often

- A lot of apps let you "sign up" with just email + password and mark you as unverified, but still create the row in the `users` table.
- The OAuth linking logic usually checks `email` only, not `email_verified = true`.
- Devs test the happy path (real user signs up, real user logs in) and never test "attacker signs up first, real user OAuths in later."

It's basically a race, except the attacker isn't racing anyone — they can just sit and wait for months.

---

## How I'd test for it

1. Make a burner email you control, or use a test email you can watch.
2. Sign up on target with email/password only. Don't verify the email.
3. Check: does the app say "account created" / let you sit logged in / show a dashboard? If yes, that's step one done — the account exists and is claimable.
4. Now log out, hit "Sign in with Google/Facebook/etc." using an OAuth account tied to that same email.
5. See what happens:
   - Does it log you straight into the existing (attacker-made) account?
   - Does it ask you to confirm/verify the pre-existing password first?
   - Does it merge silently with no warning?

If step 5 logs you straight in with zero friction, you found it.

---

## The fix (for devs reading this)

- Don't treat an unverified email account as "real." Either don't create the row until email is verified, or clearly mark it unverified and **never link OAuth to an unverified account automatically.**
- When linking OAuth to an existing email, require the user to prove they own the existing account first (confirm current password, or send a "someone tried to link Google to your account" email and require action).
- Expire/delete unverified signups after a short time (24-48h) so the trap can't just sit there forever.

---

## TL;DR

If a site lets you register with plain email/password, doesn't force verification, and *also* supports OAuth login tied by email — assume Pre-Account Takeover is possible until proven otherwise. It's a cheap bug to test for and a really quiet one to get burned by.

![Pre-Account Takeover via OAuth flow]({{ '/assets/img/pre-ato-oauth-flow.png' | relative_url }})

---

**Happy Hunting,**
*Falcon0x1*
