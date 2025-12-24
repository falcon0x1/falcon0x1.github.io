---
title: "Android Network Traffic Interception & Cleartext Risks"
date: 2025-12-24 11:00:00 +0200
categories: [Android, Mobile Security]
tags: [android, network, cleartext, mitm, interception, traffic-analysis]
toc: true
---

## Network Requests on Android

![](/assets/img/android-http-request.png)
Android applications are not allowed to perform blocking network operations on the main (UI) thread. Any direct HTTP request executed on the main thread will trigger `NetworkOnMainThreadException`. This design choice prevents UI freezes but also forces developers to offload networking into background executors, threads, or async frameworks. From a security perspective, this separation is important because network behavior often becomes harder to trace and audit when hidden behind abstractions.

## INTERNET Permission

![](/assets/img/android-internet-permission.png)
All Android network communication depends on the `android.permission.INTERNET` permission. Without it, requests fail silently, which can mislead testers during dynamic analysis. Reviewing the manifest is always the first step in assessing an app’s network attack surface.

## Cleartext Traffic Exposure

![](/assets/img/cleartext-http-traffic.png)
Android blocks cleartext HTTP traffic by default. However, developers can override this protection using `usesCleartextTraffic=true` or a permissive network security configuration. When this happens, sensitive data becomes visible to any attacker capable of passive network monitoring or active MITM interception.

## Emulator Packet Capture

![](/assets/img/emulator-wireshark.png)
Starting the Android emulator with `-tcpdump` enables full packet capture at the virtual network interface level. This approach bypasses app-level protections and reveals raw HTTP traffic directly, making it ideal for detecting unintended plaintext communication.

## Proxy Trust Model

![](/assets/img/android-cert-trust.png)
Modern Android versions trust only system certificate authorities by default. User-installed certificates are ignored unless explicitly allowed. This significantly reduces the effectiveness of casual MITM attacks but also introduces configuration-based weaknesses when developers relax trust anchors.

## Forcing TLS Interception

![](/assets/img/system-cert-injection.png)
On rooted devices or emulators, proxy certificates can be injected into the system trust store. This restores full TLS interception capabilities, even for apps that do not trust user certificates. Android 14 introduces additional complexity due to APEX-based certificate handling, but interception remains possible with proper mount injection.

## VPN-Based Traffic Control

![](/assets/img/android-vpn-intercept.png)
VPN-based interception tools operate below the application layer. They can redirect traffic, spoof DNS responses, and transparently proxy HTTP(S) requests, even when apps explicitly ignore proxy settings. This makes VPN-based MITM one of the most powerful techniques during mobile testing.

## Mini Challenge

Let’s think like a curious tester and have some hands-on fun.

1. Capture the PocketHexMap HTTP traffic using emulator tcpdump or a transparent proxy.
2. Look for endpoints that return file paths or filenames over cleartext HTTP.
3. Gently tweak an intercepted response to include a crafted filename and payload.
4. Check whether the app writes the file to:
   `/data/media/0/Android/data/io.hextree.pocketmaps/files/Download/pocketmaps/downloads/`

**Question:** Which missing validation or trust assumption in the network layer allows this behavior to happen?
