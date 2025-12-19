---
title: "Android Intents & Activities – Security Notes"
date: 2025-12-17 10:00:00 +0200
categories: [Android, Mobile Security]
tags: [android, intents, activities, pentesting, hextree]
toc: true
---

## TL;DR

- Intents are Android’s inter-process communication (IPC) mechanism  
- Exported activities act as external entry points  
- Incoming intent data is fully attacker-controlled  
- Most Android logic abuse starts with intents  
- Client-side trust assumptions are invalid  

---

## Context

This note documents foundational Android concepts learned from a **penetration testing perspective** using HexTree.

The focus is not on UI development, but on **how Intents and Activities behave internally**, and why they represent one of the **primary Android attack surfaces**.

---

## Concept Overview

### Intents

Intents are Android’s IPC mechanism.  
They allow one application to request an action from another application or system component.

Key points:
- Intents describe *what* the app wants to do, not *how*
- The Android OS resolves which component can handle the intent
- Intents can cross application boundaries
- Data passed via intents is untrusted by default

---

### Activities

Activities are user-facing entry points.

If an activity is **exported**, it can be launched by **external applications**, not only by the owning app.

Security implication:
- Exported activities behave like public APIs
- Any app (or attacker) can invoke them if not properly restricted

---

## Attack Surface Mapping

| Component | Risk |
|--------|------|
| Exported Activity | External invocation |
| Intent Extras | Injection / tampering |
| Implicit Intents | Uncontrolled routing |
| Business Logic in Activity | Logic abuse |
| Client-side Validation | Fully bypassable |

---

## Sending Intents (Outbound)

Example of sending an implicit intent to open a URL:

```java
Intent browserIntent = new Intent(
    Intent.ACTION_VIEW,
    Uri.parse("https://hextree.io/")
);
startActivity(browserIntent);
````

Explanation:

* `ACTION_VIEW` expresses the intention to view data
* The OS decides which application can handle it
* The calling app does not control the destination

Security relevance:

* Implicit intents allow interaction with other apps
* Poor assumptions can lead to abuse chains or data leakage

---

## Receiving Intents (Inbound)

For an app to receive intents from other apps, an activity must be **exported** and declare an `intent-filter`.

Example `AndroidManifest.xml`:

```xml
<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <data android:mimeType="text/plain" />
    <category android:name="android.intent.category.DEFAULT" />
</intent-filter>
```

Handling the intent inside the activity:

```java
Intent intent = getIntent();
```

Security relevance:

* Incoming intent data is attacker-controlled
* Missing validation enables logic abuse
* Sensitive actions may be triggered without UI interaction

---

## Common Abuse Scenarios

* Launching exported activities directly via ADB
* Injecting unexpected intent extras
* Triggering privileged flows without user interaction
* Reusing internal activities for unauthorized actions
* Bypassing navigation logic through direct activity access

---

## Practical Testing Angle

Exported activities can be invoked externally using ADB:

```bash
adb shell am start \
  -n com.target.app/.ExportedActivity \
  --es key injected_value
```

Why this matters:

* Confirms whether an activity is externally accessible
* Allows manipulation of intent extras
* Bypasses normal application flow and UI checks

---

## Reverse Engineering Observation

When decompiling the application using `jadx`:

* Activity code remains largely readable
* Intent handling logic is visible
* Developer assumptions are exposed
* Security checks can be identified and tested

This reinforces that **client-side logic cannot be trusted**.

---

## Debugging & Analysis

Using Android Studio:

* The debugger allows runtime inspection of intent data
* Activity transitions can be traced step-by-step
* Multi-step attack paths can be validated

Debugging is essential for reliable Android exploitation.

---

## Defensive Notes (Developer Perspective)

* Avoid exporting activities unless strictly required
* Validate all incoming intent extras
* Prefer explicit intents for internal navigation
* Enforce permission checks on sensitive components
* Never rely on client-side validation for security

---

## Challenge Result

The challenge flag was obtained by modifying **only the Activity Java code**.
No changes to `AndroidManifest.xml` were required.

```
HTX{read-or-modify-sources-gha82f}
```

---

## Why This Matters

Intents and Activities are often treated as basic Android concepts.
In reality, they define how **trust boundaries are crossed**.

Every exported activity is an API.
Every intent extra is user input.
Every assumption is an attack opportunity.
