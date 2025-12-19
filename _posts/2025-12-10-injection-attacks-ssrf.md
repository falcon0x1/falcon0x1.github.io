---
title: "API Injection Attacks & Server-Side Request Forgery (SSRF)"
date: 2025-12-10 10:00:00 +0200
categories:
  - API
  - Injection
tags:
  - api-security
  - injection
  - sqli
  - nosqli
  - command-injection
  - ssrf
toc: true
---

## Summary
Today I practiced **Injection vulnerabilities** and **Server-Side Request Forgery (SSRF)** in APIs.

Using fuzzing techniques and multiple tools, I learned how improper input handling can allow attackers to manipulate backend queries, execute system commands, or force the server to make unintended internal requests.

---

## Injection Attacks

Injection vulnerabilities occur when **untrusted input is interpreted as code or logic** by the backend.

I focused on fuzzing:
- Query parameters
- Headers
- POST / PUT request bodies

The goal was to identify **unexpected behavior**, not just obvious errors.

---

### SQL Injection (SQLi)

SQL Injection occurs when user input is concatenated into database queries without proper sanitization.

Common indicators:
- SQL syntax errors
- Authentication bypass
- Boolean-based behavior changes

Example payloads:
```

' OR 1=1--
" OR "1"="1
%00

````

Verbose database errors often reveal:
- Database type
- Query structure
- Backend logic

---

### NoSQL Injection (NoSQLi)

NoSQL Injection targets databases like MongoDB that accept structured query objects.

Example payloads:
```json
{ "$gt": "" }
{ "$ne": null }
{ "$where": "sleep(1000)" }
````

I practiced exploiting **filter-based logic flaws**, including bypassing coupon validation and triggering server-side delays.

---

### OS Command Injection

Command Injection happens when user input reaches system-level commands.

Common separators:

```
;  &&  ||  |  &
```

OS-specific payloads:

* Linux: `ls`, `whoami`, `ifconfig`
* Windows: `dir`, `whoami`, `ipconfig`

Knowing the underlying OS significantly increases exploit reliability.

---

## Server-Side Request Forgery (SSRF)

SSRF occurs when an application fetches a user-supplied URL **without proper validation**.

This allows attackers to:

* Access internal services
* Reach cloud metadata endpoints
* Bypass network controls

---

### In-Band SSRF

In-band SSRF returns the fetched content directly in the response.

Example:

```json
"inventory": "http://localhost/secrets"
```

If successful, the server may return:

* Internal tokens
* Credentials
* Configuration data

---

### Blind SSRF

Blind SSRF does not return the response but **still performs the request**.

I used **webhook.site** to detect outbound requests.
When the server contacted my webhook URL, SSRF was confirmed.

---

### Practical SSRF Testing Workflow

* Identify parameters that accept URLs
* Replace values with controlled endpoints
* Monitor outbound traffic
* Test internal IP ranges and metadata endpoints

---

## Tools Used

* Burp Suite (Proxy, Repeater, Intruder)
* Postman Collection Runner
* WFuzz
* webhook.site

---

## Security Impact

Injection and SSRF vulnerabilities can lead to:

* Database compromise
* Remote code execution
* Internal network exposure
* Cloud credential leakage

These issues often act as **entry points** for further exploitation.

---

## Key Takeaway

Injection attacks and SSRF are not always obvious.

By **fuzzing broadly**, observing anomalies, and testing server behavior rather than just responses, attackers can uncover deep and high-impact vulnerabilities.
