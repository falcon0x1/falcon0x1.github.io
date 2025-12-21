---
title: "Android Attack Surface: Activities & Intents"
date: 2025-12-21 21:00:00 +0200
categories: [Android, Mobile Security]
tags: [android, pentesting, activities, intents, attack-surface]
toc: true
---

## TL;DR

- Every UI screen maps to an Activity  
- Exported components expand the attack surface  
- Intents are a primary entry point for untrusted input  

---

## Threat Model Context

From a penetration tester’s perspective, Android apps expose functionality through components.
Misconfigured Activities combined with unvalidated Intents frequently lead to logic abuse,
unauthorized access, or hidden functionality exposure.

---

## Activities as an Attack Surface

Activities are user-facing entry points.

Security impact:

- Activities are launched via Intents
- Exported Activities are externally reachable
- Sensitive logic inside Activities becomes attacker-accessible

### Manifest Red Flag

```xml
<activity
    android:name=".TargetActivity"
    android:exported="true" />
````

* Launchable via `adb`
* Launchable by other apps
* No permission boundary enforced

---

## Intents: Data Entry Vector

```java
Intent intent = getIntent();
String action = intent.getAction();
```

* All Intent data is attacker-controlled
* Actions, extras, and data URIs must be validated
* Lifecycle assumptions are exploitable

---

## Visualizing the Exposure

![Exported activity in AndroidManifest.xml] (/assets/img/exported-activity-manifest.png)

---

## Attacker Checklist

* [ ] Enumerate exported Activities
* [ ] Trigger components via `adb shell am start`
* [ ] Inject crafted Intent actions and extras
* [ ] Observe crashes, bypasses, or hidden flows

---

## Key Takeaways

* Activities are not private by default
* Intents must be treated as untrusted input
* The attack surface starts at the manifest
