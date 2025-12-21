---
title: "Android Pentesting Notes – Weather Apps & API Discovery"
date: 2025-12-20 10:00:00 +0200
categories: [Android, Mobile Security]
tags: [android, jadx, reversing, api-security, pentesting]
toc: true
---

## TL;DR

- Obfuscation **does not protect client-side secrets**
- Backend URLs and API keys are often recoverable
- In mobile pentesting, **speed and focus matter more than full code understanding**

---

## Why This Note Exists

This write-up documents my **first hands-on Android reverse-engineering exercise** using real-world **weather applications**.

The objective was **not** to understand the entire app logic, but to answer a few high-impact security questions:

- What backend API does the app communicate with?
- How does the app authenticate?
- Why are some features disabled?

This reflects how Android apps are assessed during **real penetration tests**.

---

## Lab Environment

- Android Emulator / Physical Device  
- `adb` for installation and inspection  
- `jadx-gui` for decompilation and static analysis  

### Target APKs

- `biz.binarysolutions.weatherusa.apk`
- `io.hextree.weatherusa.apk`

---

## Pentesting Strategy: Think Like an Attacker

These applications were **heavily obfuscated** — and that turned out to be irrelevant.

Instead of reading classes line by line, I followed a **goal-oriented approach**:

- Ignore class names and package structure
- Use **Global Search in jadx**
- Search for meaningful strings such as:
  - `http`
  - `https`
  - `api`
  - `weather`
  - `key`

This mirrors real-world assessments where **time is limited** and results matter.

---

## API Discovery


::contentReference[oaicite:0]{index=0}


Using jadx’s global search immediately revealed:

- Clear-text backend URLs
- Hardcoded API endpoints
- API keys embedded in string resources

Despite obfuscation, **string literals remained fully visible**, which is a common and critical weakness in Android apps.

---

## Authentication Mechanism

Further inspection showed that:

- Authentication relied on a **static API key**
- The key was stored inside **`strings.xml`**
- No dynamic token exchange or backend validation was observed

This is a **classic mobile anti-pattern** and frequently exploitable.

---

## Disabled Features: Client-Side Trust

Some weather functionality appeared “disabled” in the UI.

Analysis revealed that:

- The restriction was enforced **entirely client-side**
- No server-side validation existed
- Logic checks could be bypassed by:
  - Repackaging
  - Runtime manipulation
  - Direct API calls

This reinforces why **client-side checks should never enforce security**.

---

## Manual API Interaction

Once the API details were extracted:

- Requests were reconstructed manually
- Testing was performed using:
  - `curl`
  - Burp Suite
- Required headers and API keys were reused successfully

At this point, the mobile app becomes **just another API client**.

---

## Key Takeaways

- Obfuscation ≠ security
- Secrets inside Android apps are **recoverable**
- Focus on **functionality**, not full decompilation
- Mobile pentesting is about **finding leverage quickly**


*Learning Android security starts with understanding how little the client can be trusted.*
