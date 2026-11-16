---
name: ci-failure-triage
description: "Use this skill for CI log analysis, local reproduction, root cause isolation, targeted fixes, rerun strategy."
---

# CI Failure Triage

## Task Decisions

1. Locate the first meaningful failing step and pin its revision, environment and failing command before rerunning.
2. Distinguish deterministic code defects from infrastructure or order-dependent flakes; a green retry alone does not establish a fix.

Use this skill for Programming tasks focused on CI log analysis, local reproduction, root cause isolation, targeted fixes, rerun strategy.

## Guardrails

- Do not retry CI blindly without identifying a likely failure cause.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
