---
title: "TIL: JWT Attacks & Burp Sequencer"
date: 2025-12-08
tags: [til, cybersecurity, pentesting, api, jwt, burp]
---

# Today I Learned — JWT Attacks & Burp Sequencer

## Summary
Today I focused on understanding how JSON Web Tokens (JWTs) can be attacked when their implementation is weak.  
I explored common attack vectors, learned how attackers forge or manipulate tokens, and used Burp Suite’s Sequencer to measure token randomness.  
Overall, I gained practical experience in evaluating token-based authentication systems.

---

## What I Learned in Detail

### 1. JWT Structure and Weaknesses  
JWTs are not encrypted; they are only Base64URL-encoded.  
This means anyone can read the header and payload, so the security of the token depends entirely on **signature validation**.

I studied several implementation mistakes:
- Accepting the token without verifying the signature.
- Allowing the algorithm to be switched (e.g., RS256 → HS256).
- Using weak secrets in HS256, making brute-force attacks possible.
- Generating predictable tokens with low entropy.

Understanding these mistakes helped me see how privilege escalation and authentication bypass can occur.

---

## Tools Used
- Burp Suite (Sequencer module)  
- jwt_tool  
- Postman  

These tools allowed me to analyze JWT behavior, generate forged tokens, and test real attack scenarios.

---

## Experiments and Findings

### 1. None Algorithm Attack  
I changed the token header to `"alg": "none"` and removed the signature entirely.  
Some weak backends incorrectly accept the token as valid, which allows an attacker to impersonate any user.

### 2. Algorithm Switching Attack  
By switching from RS256 to HS256 and using the public key as the symmetric secret, I could forge a valid token when the server didn’t enforce the algorithm defined on the backend.  
This demonstrates how a misconfigured JWT library can be exploited.

### 3. Cracking Weak Secrets  
Using jwt_tool with a wordlist:

jwt_tool TOKEN -C -d wordlist.txt

I was able to simulate a brute-force attack.  
When the HS256 secret is short or predictable, the key can be recovered quickly, allowing full token forgery.

### 4. Token Entropy Analysis with Burp Sequencer  
I sent a token response to the Sequencer and highlighted the token location.  
After collecting a large number of samples, Sequencer showed:

- Low effective entropy  
- Static characters at the beginning of the token  
- High predictability  

This means the token could potentially be guessed or brute-forced.  
It reinforced how important randomness is for secure token generation.

---

## Takeaways
- JWTs are only secure if signature verification is strict and properly implemented.  
- The “none” algorithm must always be disabled.  
- Algorithm switching must not be allowed.  
- HS256 requires a long, unpredictable secret; otherwise, it can be brute-forced.  
- Burp Sequencer is extremely valuable for detecting predictable or poorly generated tokens.  

**Next goal:** Study OWASP API Security Top 10 and map real JWT issues to these categories to structure tests more efficiently.


