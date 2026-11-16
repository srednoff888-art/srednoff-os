---
name: dependency-license-risk-audit
description: "Use this skill for dependency license review, maintenance health, vulnerability risk, replacement strategy."
---

# Dependency License Risk Audit

## Task Decisions

1. Inspect the exact resolved dependency and transitive licenses, maintenance status and applicable vulnerability advisories.
2. Separate a declared license from distribution obligations; document uncertainty rather than declaring legal clearance.

Use this skill for Security tasks focused on dependency license review, maintenance health, vulnerability risk, replacement strategy.

## Guardrails

- Do not copy OSS code unless license compatibility is confirmed.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
