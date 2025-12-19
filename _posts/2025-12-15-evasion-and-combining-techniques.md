---
title: "API Pentesting: Evasion & Combining Techniques"
date: 2025-12-15 10:00:00 +0200
categories:
  - API
  - Evasion
tags:
  - api-security
  - evasion
  - waf
  - rate-limit
  - bola
  - bfla
  - business-logic
toc: true
---

## Summary
Today I learned that **finding a vulnerability is rarely the end of the story**.

Real-world impact usually comes from:
- **Bypassing security controls**
- **Combining multiple weaknesses together**

This mindset is what separates basic vulnerability discovery from **real API exploitation**.

---

## Evasion Techniques

Many APIs rely on protections such as:
- WAFs
- Rate limiting
- Input validation rules

These controls often detect **patterns**, not intent.  
By slightly modifying payloads, it is sometimes possible to bypass them.

---

### Common Evasion Methods

Techniques I practiced include:
- URL encoding and double encoding
- Case switching in endpoints and parameters
- Adding string terminators and special characters
- Manipulating headers and request structure

The goal is not to break functionality, but to **avoid detection logic**.

---

## Combining Vulnerabilities

Low-severity issues often become **critical** when chained together.

Examples of effective combinations:
- **BOLA + BFLA** → full privilege escalation
- **Improper Assets Management + Brute Force** → account takeover
- **Excessive Data Exposure + Authentication flaws**
- **Mass Assignment + Business Logic abuse**

Each individual issue may seem limited, but together they create real risk.

---

## Practical Mindset Shift

Instead of stopping at:
> “This endpoint is vulnerable”

I learned to ask:
- What else can interact with this?
- Can this bypass an existing control?
- Can this increase impact?
- Can this be automated?

This approach turns isolated bugs into **attack chains**.

---

## Tooling Support

Tools like **Burp Suite** and **WFuzz** help automate evasion and chaining by supporting:
- Multiple encoders
- Payload transformations
- Prefixes and suffixes
- Large-scale request testing

Automation makes bypass techniques **repeatable and reliable**.

---

## Security Impact
When evasion and chaining are successful, the result is often:
- Full account compromise
- Authorization bypass
- Business logic abuse
- Large-scale data exposure

Security controls that are not tested against evasion techniques provide a **false sense of safety**.

---

## Key Takeaway
Never stop at the first vulnerability.

Real API exploitation comes from:
- Thinking beyond single issues
- Understanding how controls fail
- Combining weaknesses strategically

This mindset is essential for effective API pentesting.
