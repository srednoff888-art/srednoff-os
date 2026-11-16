---
name: typescript-strictness-migration
description: "Use this skill for TypeScript strict mode, noImplicitAny, type narrowing, migration sequencing, typed APIs."
---

# Typescript Strictness Migration

## Task Decisions

1. Scope stricter settings to a package or boundary and replace unsafe casts with runtime validation or useful type constraints.
2. Test emitted/runtime behavior and public type compatibility; do not hide remaining errors behind broad suppressions.

Use this skill for Programming tasks focused on TypeScript strict mode, noImplicitAny, type narrowing, migration sequencing, typed APIs.

## Guardrails

- Do not silence type errors with broad any or unchecked assertions unless justified.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
