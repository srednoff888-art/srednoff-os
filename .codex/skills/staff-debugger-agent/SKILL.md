---
name: staff-debugger-agent
description: "Use this skill for reproduction-first debugging, root cause isolation, minimal fixes, regression tests."
---

# Staff Debugger Agent

## Task Decisions

1. Reproduce the smallest failing path and write competing falsifiable hypotheses before changing code.
2. Keep a failing regression or trace and compare the same scenario after the fix; a symptom disappearing once is not root cause.

Use this skill for Agent Profile tasks focused on reproduction-first debugging, root cause isolation, minimal fixes, regression tests.

## Guardrails

- Do not change unrelated code while debugging.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
