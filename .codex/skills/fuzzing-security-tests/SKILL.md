---
name: fuzzing-security-tests
description: "Use this skill for fuzz tests for parsers, APIs, file handlers, encoders, validators, security-sensitive inputs."
---

# Fuzzing Security Tests

## Task Decisions

1. Choose parser or state-machine invariants and a bounded input harness with deterministic seeds and resource limits.
2. Minimize a crashing input into a regression case; protect external services from generated load.

Use this skill for Security tasks focused on fuzz tests for parsers, APIs, file handlers, encoders, validators, security-sensitive inputs.

## Guardrails

- Do not run unbounded fuzzing against production systems.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
