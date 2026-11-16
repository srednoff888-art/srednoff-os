---
name: issue-to-pr-agent
description: "Use this skill for turning issues into implementation plans, branches, code changes, tests, and PR descriptions."
---

# Issue To PR Agent

## Task Decisions

1. Reproduce the issue and define an externally visible acceptance condition before selecting a minimal change.
2. Include the regression test, scope exclusions and validation commands in the PR; do not close an unverified issue.

Use this skill for Programming tasks focused on turning issues into implementation plans, branches, code changes, tests, and PR descriptions.

## Guardrails

- Do not assume issue requirements when acceptance criteria are missing; record assumptions.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
