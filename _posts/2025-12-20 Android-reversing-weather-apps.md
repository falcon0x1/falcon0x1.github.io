---
title: "Android Pentesting Notes – Weather Apps & API Discovery"
date: 2025-12-20 10:00:00 +0200
categories: [Android, Mobile Security]
tags: [android, jadx, reversing, api-security, pentesting]
toc: true
---------

## TL;DR

* Obfuscation does not protect client-side secrets
* URLs and API keys are often discoverable via global search
* Focus on *what you are looking for*, not full code comprehension

---

## Context

This note documents my first practical reverse-engineering exercise on **real Android weather applications**, focusing on extracting backend details rather than understanding the full codebase.

The primary goal was to answer:

* What API does the app talk to?
* How does it authenticate?
* Why is functionality disabled?

---

## Lab Setup

* Emulator / physical device
* `adb` for installation
* `jadx-gui` for decompilation and search

APKs analyzed:

* `biz.binarysolutions.weatherusa.apk`
* `io.hextree.weatherusa.apk`

---

## Strategy: Focus on the Goal

The application is obfuscated — **and that does not matter**.

Instead of reading classes:

* Use **jadx Global Search**
* Search for keywords:

  * `http`
  * `https`
  * `api`
  * `weather`
  * `key`

This approach mirrors real-world pentesting where time matters.

---

## Findings

### API Discovery

* The backend endpoint is visible in decompiled code
* Obfuscation does not hide string literals effectively

### Authentication Method

* API key stored inside **string resources**
* Common real-world anti-pattern

### Disabled Weather Updates

* Feature disabled by **client-side logic checks**
* Not enforced server-side

---

## Manual API Testing

Once the API details are known:

* Rebuild the request manually
* Use tools such as **Burp Suite** or `curl`
* Include required headers and API key

---

## Image

![adx global search result showing the weather API endpoint and API key] (/assets/img/jadx-global-search.png)

---

## Key Takeaways

* Obfuscation ≠ security
* Secrets in Android apps are recoverable
* Always search by *functionality*, not structure
