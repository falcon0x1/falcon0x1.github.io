---
title: "API Security: Improper Assets Management & Mass Assignment"
date: 2025-12-08 10:00:00 +0200
categories:
  - API
  - Business Logic
tags:
  - api-security
  - mass-assignment
  - improper-assets
  - business-logic
toc: true
---

## Summary
Today I practiced two **high-impact API vulnerabilities** that frequently lead to **account takeover** and **business logic abuse**:

- **Improper Assets Management**
- **Mass Assignment**

Both issues often exist silently in production systems and are commonly missed during superficial testing.

---

## Improper Assets Management

Improper Assets Management occurs when **old, internal, or test API versions** remain accessible in production.

Common examples:
```

/api/v1
/api/v2
/api/test
/api/internal

````

Even if the latest version is secure, **older versions may still be vulnerable**.

---

### Real Attack Scenario
The OTP verification endpoint behaved differently across versions:

- **v3**
  - Rate limited
  - Secure

- **v2**
  - No rate limiting
  - No brute-force protection

By targeting the older endpoint, I was able to **brute-force the OTP** and reset the victim’s password.

**Impact:**  
Full account takeover using a deprecated API version.

---

## Mass Assignment

Mass Assignment happens when an API **blindly accepts user-controlled parameters** and maps them directly to backend objects.

---

### Example

Legitimate request:
```json
{
  "email": "user@test.com",
  "password": "123456"
}
````

Malicious request:

```json
{
  "email": "user@test.com",
  "password": "123456",
  "isAdmin": true
}
```

If the backend does not whitelist allowed fields, the attacker gains **unauthorized privileges**.

---

### Real Lab Result

I was able to:

* Create my own store product
* Set a **negative price**
* Purchase the product
* Increase my account balance instead of decreasing it

This confirmed a **critical Mass Assignment vulnerability** combined with business logic flaws.

---

## Key Lessons

* Never trust client-side input
* Always whitelist allowed fields
* Deprecated API versions are dangerous
* Business logic must be validated server-side

---

## Tools Used

* Postman
* Burp Suite
* Param Miner
* WFuzz

---

## Security Impact

When combined, these vulnerabilities can lead to:

* Account takeover
* Privilege escalation
* Financial abuse
* Full business logic compromise

---

## Key Takeaway

A secure API is not just about **authentication**.

It requires:

* Version control
* Strict input validation
* Continuous removal of legacy endpoints

Ignoring old assets is an attacker’s opportunity.
