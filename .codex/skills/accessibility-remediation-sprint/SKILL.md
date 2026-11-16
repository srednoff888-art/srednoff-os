---
name: accessibility-remediation-sprint
description: "Use this skill for turning accessibility audit findings into fixes, tasks, tests, and regression checks."
---

# Accessibility Remediation Sprint

## Task Decisions

1. Turn each finding into a reproducible affected route/control and the relevant success criterion, including severity and an owner.
2. Retest the original keyboard or assistive-technology failure after the fix; keep automated checks separate from manual coverage.

Use this skill for Web Design tasks focused on turning accessibility audit findings into fixes, tasks, tests, and regression checks.

## Guardrails

- Do not close accessibility findings without verifying keyboard and screen-reader impact where feasible.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
