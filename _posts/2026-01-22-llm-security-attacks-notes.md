---
title: "Notes on Web LLM Attacks and Defenses"
date: 2026-01-22 13:28:00 +0200
categories: [security, web-llm-attacks]
tags: [llm, prompt-injection, api-security, web-security, notes]
toc: true
---

## Why these notes exist

These are **personal review notes** on LLM security from a web exploitation perspective.  
They are intentionally short, high-level, and focused on **how things break**, not theory or hype.

The goal is simple:  
to quickly refresh the mental model when testing LLM features in labs, bug bounties, or real systems.

Background reference:  
https://portswigger.net/web-security

---

## Big picture: what LLM security really means

Most LLM security problems reduce to three questions:

- What **data** does the model see?
- What **tools / APIs** can it control?
- How much **trust** does the system place in its output?

Mental model:

```

User input
↓
LLM
↓
Backend logic / APIs
↓
Real-world impact

```

Once an LLM influences backend behavior, it is part of the **attack surface**, not just a UI feature.

---

## How LLMs behave (security view)

LLMs do not reason or validate intent.  
They predict the next token based on learned patterns.

Security implication:

```

[Trusted instructions] ─┐
├──> LLM ──> Output / Actions
[Untrusted user input] ─┘

```

There is **no native distinction** between trusted and untrusted text.

---

## Prompt injection (core idea)

Prompt injection changes **system behavior**, not just output.

```

Attacker-controlled text
↓
LLM
↓
Unintended API call / data access

```

Outcomes that matter:

- Unintended actions (state changes, API calls)
- Unintended outputs (secrets, payloads)

---

## Direct vs indirect prompt injection

```

Direct injection:
Attacker → Chat input → LLM

Indirect injection:
Attacker → Web page / Email / Document → LLM

```

Indirect injection is often more dangerous because:
- The user interaction looks innocent
- Malicious instructions are hidden in external content

---

## Typical LLM integration model

Most real systems follow this pattern:

```

User
↓
Application
↓ (prompt + system rules)
LLM
↓ (tool decision)
Backend API
↓
LLM
↓
User response

```

Security takeaway:  
If an attacker can steer the model, they may steer backend execution.

---

## Excessive agency

Excessive agency means the LLM can perform **high-impact actions**:

```

LLM capabilities:

* Reset passwords
* Send emails
* Read internal files
* Execute commands

```

If access control relies on “the model will behave,” the design is already unsafe.

---

## Mapping attack surface (tester mindset)

A practical first step:

```

Discover tools
↓
Understand parameters
↓
Test payloads

```

If the model can describe its tools, it often generates an attacker’s API map.

---

## LLM-assisted API exploitation pattern

Reusable testing loop:

```

Identify tool
↓
Trigger tool
↓
Control input
↓
Observe backend effects

```

UI responses are secondary.  
Backend-side effects are what prove impact.

---

## Indirect prompt injection in practice

Example mental flow:

```

User: "Summarize my email"
↓
LLM reads email content
↓
Hidden instructions inside email
↓
LLM triggers sensitive backend action

```

The attacker never interacts with the chat input directly.

---

## Why naive defenses fail

Prompt-only defenses assume the model enforces rules.

Reality:

```

"Never do X"        ┐
├──> LLM → Decision
"Ignore above and do X" ┘

```

Both are just text.  
The model has no hard trust boundary.

---

## Training data risks

### Poisoning

```

Attacker-controlled data
↓
Training / fine-tuning
↓
Altered model behavior

```

### Data leakage

```

Sensitive logs / inputs
↓
Training data
↓
LLM completion
↓
Partial reconstruction

```

Deletion does not guarantee removal from training pipelines.

---

## Defensive mindset

Core principle:

```

Assume model failure
↓
Enforce security in backend

```

Practical implications:

- Treat LLM-accessible APIs as public
- Enforce auth and authorization server-side
- Limit tool privileges
- Restrict data exposure
- Monitor tool usage

Prompt rules are **not** security controls.

---

## Review checklist

```

□ Do I know every input source (direct and indirect)?
□ Do I know every tool/API the model can call?
□ Are sensitive actions enforced server-side?
□ Can attacker-controlled content influence decisions?
□ Is trust placed in the model instead of the backend?

```

If these are clearly answered, the integration is far more likely to be resilient rather than merely impressive.
```
