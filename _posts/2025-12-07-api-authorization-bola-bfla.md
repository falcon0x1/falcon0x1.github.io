---
title: "API Authorization Attacks: BOLA & BFLA"
date: 2025-12-07 10:00:00 +0200
categories: [API, Authorization]
tags: [api-security, bola, bfla, idor, pentesting]
toc: true
---

## Summary
Today I practiced two of the **most critical API authorization vulnerabilities**:

- **Broken Object Level Authorization (BOLA)**
- **Broken Function Level Authorization (BFLA)**

These issues are simple to exploit, easy to miss, and often lead to **severe data exposure or account takeover** in real-world APIs.

---

## Why Authorization Bugs Are Dangerous
Authentication answers:
> *Who are you?*

Authorization answers:
> *What are you allowed to do?*

Many APIs rely only on tokens and forget to verify **ownership** and **permissions** on every request.  
This creates silent but devastating vulnerabilities.

---

## Broken Object Level Authorization (BOLA)

BOLA occurs when an API does **not verify that the authenticated user owns the requested object**.

### Legitimate Request (User B)
```http
GET /identity/api/v2/vehicle/943186f6-b753-4629-a9dc-cdb444fb90d/location
Authorization: Bearer USER_B_TOKEN
````

### Attack Scenario (User A)

```http
GET /identity/api/v2/vehicle/943186f6-b753-4629-a9dc-cdb444fb90d/location
Authorization: Bearer USER_A_TOKEN
```

### Result

User A successfully accessed **User B’s live GPS location**.

**Impact:**
Sensitive data exposure → privacy violation → potential physical risk.

---

## Broken Function Level Authorization (BFLA)

BFLA happens when users can access **actions outside their role**.

### Admin Endpoint Exposed

```http
DELETE /identity/api/v2/admin/videos/758
Authorization: Bearer USER_B_TOKEN
```

### Response

```json
{
  "message": "User video deleted successfully",
  "status": 200
}
```

A **normal user** was able to execute an **admin-only function**.

**Impact:**
Privilege escalation → destructive actions → full platform abuse.

---

## Visualizing the Problem

![API Authorization Flow – BOLA vs BFLA](/assets/img/api-bola-bfla.png)

This diagram highlights the missing authorization checks:

* No ownership validation (BOLA)
* No role enforcement (BFLA)

---

## Key Lessons

* Tokens do **not** equal authorization
* Every request must validate:

  * User identity
  * User role
  * Resource ownership
* IDs in URLs are **attack surfaces**
* Admin endpoints must never rely on client trust

---

## Tools Used

* Postman
* Burp Suite (Proxy, Repeater)

---

## Security Impact

Authorization bugs are among the **highest impact API vulnerabilities**.

They often lead to:

* Mass data leakage
* Account takeover
* Business logic abuse
* Regulatory violations

---

## Key Takeaway

If an API checks *who you are*
but not *what you are allowed to access*

👉 **Authorization is already broken.**
