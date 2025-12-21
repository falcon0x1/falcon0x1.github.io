---
title: "Android Pentesting Notes – Activities, Intents & Attack Surface"
date: 2025-12-21 10:00:00 +0200
categories: [Android, Mobile Security]
tags: [android, intents, activities, attack-surface, pentesting]
toc: true
---------

## TL;DR

* Every screen is backed by an Activity
* Exported Activities are externally reachable
* Intents are a primary Android attack surface

---

## Context

This note focuses on **Android application attack surface discovery**, specifically how Activities and Intents can be abused when exposed.

---

## Android Activities

An Activity represents a single screen.

Key points:

* Activities render UI
* Activities are started via Intents
* Activities may be **exported**

---

## AndroidManifest.xml

The first file to inspect:

```xml
<activity android:exported="true" />
```

Why this matters:

* Exported Activities can be launched by:

  * adb
  * Other apps

---

## Intents Explained

Official definition:

> "An intent is an abstract description of an operation to be performed."

Practical definition:

> Declare what you want to do and let Android handle routing.

---

## Starting Activities

```java
Intent intent = new Intent();
intent.setClassName("pkg", "TargetActivity");
startActivity(intent);
```

Incoming Intents:

```java
Intent intent = getIntent();
```

This is where **external data enters the app**.

---

## Attack Surface Summary

* Activities
* Services
* Broadcast Receivers

All can be targeted if exported and insufficiently validated.

---

## Image

![AndroidManifest.xml showing android:exported="true"] (/assets/img/exported.png)

---

## Key Takeaways

* Always enumerate exported components
* Intents must never be trusted
* Attack surface exists by default
