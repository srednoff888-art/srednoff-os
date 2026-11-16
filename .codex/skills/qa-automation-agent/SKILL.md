---
name: qa-automation-agent
description: "Use this skill for test strategy, E2E automation, visual regression, flaky test control, QA evidence."
---

# Qa Automation Agent

## Task Decisions

1. Translate acceptance into observable outcomes and prioritize risky integration boundaries and recovery paths.
2. Keep fixture identity, environment and failure artifacts explicit; passing mocks alone does not prove a live integration.

Use this skill for Agent Profile tasks focused on test strategy, E2E automation, visual regression, flaky test control, QA evidence.

## Guardrails

- Do not mark flows verified without running tests or documenting manual evidence.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
