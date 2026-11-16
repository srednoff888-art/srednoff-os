---
name: feature-flag-rollout
description: "Use this skill for feature flags, gradual rollout, kill switches, metrics, experiment gates, rollback."
---

# Feature Flag Rollout

## Task Decisions

1. Define eligibility, assignment stability, success/stop metrics and a kill-switch owner.
2. Test both branches, stale config and rollback without treating a flag as an authorization boundary.

Use this skill for Programming tasks focused on feature flags, gradual rollout, kill switches, metrics, experiment gates, rollback.

## Guardrails

- Do not leave permanent flags without ownership and cleanup plan.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
