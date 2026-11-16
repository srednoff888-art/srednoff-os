---
name: mutation-testing-strategy
description: "Use this skill for mutation testing ideas, weak assertion detection, test suite hardening, critical logic coverage."
---

# Mutation Testing Strategy

## Task Decisions

1. Choose behavioral assertions on the changed contract and compare surviving mutants with uncovered outcomes.
2. Improve meaningful tests rather than chasing a global score or asserting implementation details.

Use this skill for Programming tasks focused on mutation testing ideas, weak assertion detection, test suite hardening, critical logic coverage.

## Guardrails

- Do not chase 100 percent mutation scores where risk does not justify cost.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
