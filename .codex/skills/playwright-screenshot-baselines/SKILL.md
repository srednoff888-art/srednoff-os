---
name: playwright-screenshot-baselines
description: "Use this skill for Playwright screenshot comparisons, baselines, thresholds, viewport matrix, visual regression."
---

# Playwright Screenshot Baselines

## Task Decisions

1. Pin viewport, browser, fonts, data, motion and render readiness for each baseline.
2. Inspect the visual diff before accepting it; mask only intentionally nondeterministic regions, not the defect.

Use this skill for Web Design tasks focused on Playwright screenshot comparisons, baselines, thresholds, viewport matrix, visual regression.

## Guardrails

- Do not accept baselines without reviewing real screenshots first.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
