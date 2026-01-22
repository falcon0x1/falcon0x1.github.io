---
title: "Notes on Web LLM Attacks and Defenses"
date: 2026-01-22 13:28:00 +0200
categories: [security, web-llm-attacks]
tags: [llm, prompt-injection, api-security, web-security, notes]
toc: true
---

## Why these notes exist

These are **personal review notes** on LLM security from a web exploitation perspective.  
They are intentionally short, high-level, and focused on **how things break**, not on theory.

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

```mermaid
flowchart LR
    User -->|Text| LLM
    LLM -->|Actions| Backend
    Backend --> Data
````

Key idea:
Once an LLM influences backend behavior, it becomes part of the **attack surface**.

---

## How LLMs behave (security view)

LLMs do not reason or validate intent.
They predict the next token based on patterns.

Security implication:

```mermaid
flowchart LR
    TrustedText --> LLM
    UntrustedText --> LLM
```

There is **no native distinction** between trusted and untrusted input.
Everything is just text.

---

## Prompt injection (core idea)

Prompt injection changes **behavior**, not just output.

```mermaid
sequenceDiagram
    Attacker->>LLM: Malicious instructions
    LLM->>Backend: Unintended API call
```

Outcomes that matter:

* Unintended actions (API calls, state changes)
* Unintended outputs (secrets, payloads)

---

## Direct vs indirect prompt injection

```mermaid
flowchart TD
    A[Attacker Input] -->|Direct| LLM
    B[Web Page / Email / Doc] -->|Indirect| LLM
```

* **Direct**: attacker types instructions directly
* **Indirect**: attacker hides instructions in content later processed

Indirect injection is harder to detect and often more dangerous.

---

## Typical LLM integration model

Most real systems follow this pattern:

```mermaid
sequenceDiagram
    User->>App: Prompt
    App->>LLM: Prompt + system rules
    LLM->>App: Tool decision
    App->>Backend: API call
    Backend->>LLM: Result
    LLM->>User: Final answer
```

Security takeaway:
If the attacker can steer the model, they may steer backend execution.

---

## Excessive agency

Excessive agency means the LLM can perform **high-impact actions**:

```mermaid
flowchart LR
    LLM --> ResetPasswords
    LLM --> SendEmails
    LLM --> ReadFiles
    LLM --> RunCommands
```

If access control relies on “the model will behave,” the design is already broken.

---

## Mapping attack surface (tester mindset)

First testing step:

```mermaid
flowchart LR
    DiscoverTools --> ControlParams --> TestPayloads
```

If the model can describe its tools, it often generates an attacker’s API map.

---

## LLM-assisted API exploitation pattern

Reusable attack loop:

```mermaid
flowchart LR
    IdentifyTool --> TriggerTool --> ControlInput --> ObserveBackend
```

UI output is secondary.
Backend side effects are what matter.

---

## Indirect prompt injection in practice

```mermaid
sequenceDiagram
    User->>LLM: Summarize my email
    LLM->>EmailStore: Read email
    EmailStore-->>LLM: Hidden instructions
    LLM->>Backend: Sensitive action
```

The attacker never touches the chat input.

---

## Why naive defenses fail

Prompt-only defenses assume the model enforces rules.

```mermaid
flowchart LR
    SafetyPrompt --> LLM
    AttackerPrompt --> LLM
```

Both are just text.
The model has no hard priority system.

---

## Training data risks

### Poisoning

```mermaid
flowchart LR
    AttackerData --> TrainingSet --> LLMBehavior
```

### Data leakage

```mermaid
flowchart LR
    SensitiveLogs --> Training --> LLM --> Reconstruction
```

Deletion does not guarantee removal from training pipelines.

---

## Defensive mindset

Core principle:

```mermaid
flowchart LR
    AssumeFailure --> EnforceBackendControls
```

Practical implications:

* Treat LLM-accessible APIs as public
* Enforce auth and authorization server-side
* Limit tool privileges
* Restrict data exposure
* Monitor tool usage

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
