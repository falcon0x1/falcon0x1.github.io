---
title: "Android Pentesting Notes – ADB Fundamentals"
date: 2025-12-18 16:01:07 +0200
categories: [Android, Mobile Security]
tags: [adb, android, pentesting, hextree, mobile]
toc: true
---

## TL;DR

- ADB is the primary bridge between analyst and device
- Many Android attacks require ADB interaction
- File access, app management, logging, and activity triggering are possible
- Understanding ADB is mandatory for Android pentesting

---

## Context

This note documents foundational **Android Debug Bridge (ADB)** concepts learned while starting Android penetration testing labs.

ADB is a **core tool** used for:
- Device interaction
- App analysis
- Reverse engineering workflows
- Exploit validation

---

## ADB Architecture

ADB consists of three components:

- **Client** – runs on the analyst machine
- **Server** – manages communication (runs on analyst machine)
- **Daemon (adbd)** – runs on the Android device/emulator

The client communicates with the daemon through the server.

---

## Installing ADB

ADB is installed automatically with **Android Studio**.

### Configure PATH (Required)

#### Windows

Default location:
```

C:\Users<USERNAME>\AppData\Local\Android\Sdk\platform-tools

````

Steps:
1. Open *System → Advanced system settings*
2. Open *Environment Variables*
3. Edit `Path`
4. Add the platform-tools directory
5. Restart terminal

#### macOS

```bash
export PATH=~/Library/Android/sdk/platform-tools:$PATH
````

Persist by adding to `~/.zshrc`.

---

## Testing ADB

```bash
adb version
```

Expected output:

```
Android Debug Bridge version 1.0.41
```

---

## Connected Devices

```bash
adb devices
```

Multiple devices:

* `-s emulator-5554`
* `-d` → USB device

---

## adb shell

```bash
adb shell
```

Provides a Linux shell on the device.

Exit:

```bash
exit
# or Ctrl+D
```

Security note:

* Permissions here define what files you can access or exfiltrate

---

## File Transfer

### Push file to device

```bash
adb push local_file /sdcard/Downloads/
```

### Pull file from device

```bash
adb pull /sdcard/Downloads
```

Limitations:

* Only files accessible via `adb shell` can be pulled

---

## App Management via ADB

Install APK:

```bash
adb install app.apk
```

List packages:

```bash
adb shell pm list packages
adb shell pm list packages -3
```

Clear app data:

```bash
adb shell pm clear <package>
```

Inspect note:

```bash
adb shell dumpsys package <package>
```

Start activity:

```bash
adb shell am start <package>/<activity>
```

Uninstall:

```bash
adb uninstall <package>
```

---

## Logcat

```bash
adb logcat
```

Filtered logs:

```bash
adb logcat "MainActivity:V *:S"
```

Log levels:

* V Verbose
* D Debug
* I Info
* W Warning
* E Error
* F Fatal

---

## Security Relevance

* ADB bypasses UI controls
* Exported activities can be invoked directly
* Logs often leak sensitive information
* Many Android exploits rely on ADB access

---

## Key Takeaway

ADB is not optional knowledge.

If you cannot:

* Navigate a device
* Inspect apps
* Pull files
* Trigger activities

You are not ready for Android pentesting.
