---
title: "Android Pentesting Notes – APK Reversing & Tooling"
date: 2025-01-31 10:00:00 +0200
categories: [Android, Mobile Security]
tags: [apktool, jadx, reversing, android, pentesting]
toc: true
---

## TL;DR

- APKs must be aligned and signed before installation
- apktool extracts resources and smali
- jadx provides near-source Java decompilation
- Client-side code is fully exposed

---

## Context

This note documents **APK reversing workflows** used during Android pentesting and reverse engineering labs.

The goal is to:
- Inspect application logic
- Identify exposed components
- Modify and reinstall APKs safely

---

## APK Alignment & Signing (Android 11+)

### Step 1: Align APK

```bash
zipalign -f 4 input.apk output_aligned.apk
````

Verification:

```bash
zipalign -c 4 output_aligned.apk
```

---

### Step 2: Sign APK

```bash
apksigner sign \
--ks ~/.android/debug.keystore \
output_aligned.apk
```

Create keystore if missing:

```bash
keytool -genkey -v \
-keystore ~/.android/debug.keystore \
-alias androiddebugkey \
-keyalg RSA \
-keysize 2048 \
-validity 10000
```

Verify:

```bash
apksigner verify output_aligned.apk
```

---

### Step 3: Install

```bash
adb install output_aligned.apk
```

---

## apktool

```bash
apktool d app.apk
```

What apktool does:

* Extracts resources
* Disassembles DEX → smali
* Decodes AndroidManifest.xml

Use apktool to:

* Identify exported activities
* Inspect permissions
* Modify logic at smali level

---

## jadx

Launch GUI:

```bash
jadx-gui
```

Capabilities:

* Java decompilation
* Manifest navigation
* Global string search
* Activity entry-point discovery

Notes:

* `R.string` and `R.id` reference resources
* Global search is essential
* JNI calls are marked `native`

---

## JNI & Native Code

* Native methods cannot be decompiled by jadx
* Shared objects (`.so`) require:

  * strings
  * Ghidra
  * Binary Ninja

Often secrets are recoverable with:

```bash
strings libnative.so
```

---

## Obfuscation Reality

* Java retains symbols
* Dalvik bytecode is high-level
* Obfuscation is common in real apps
* Still frequently reversible

---

## Why This Matters

Android applications are **client-side code**.

That means:

* Logic is visible
* Secrets leak
* Trust assumptions fail
* Repackaging is trivial

---

## Key Takeaway

Reverse engineering is not an edge case.

It is the **default state** of Android security testing.
