---
name: mobile-crash-analytics-gate
description: Use for mobile app observability, Sentry/Firebase crash reporting, release diagnostics, and production incident readiness.
---

# Mobile Crash Analytics Gate

## Task Decisions

1. Verify release/build identity, symbol/source-map upload, sampling and privacy controls with an intentional test failure.
2. Confirm the event reaches the expected release and alert route; SDK installation alone is not observability evidence.

Use this skill for Mobile work focused on check crash reporting, source maps, release tags, breadcrumbs, privacy-safe logs, and alerting.

## Guardrails

- Do not perform destructive, paid, production, publishing, account-changing, trading, legal, financial, or externally visible actions without explicit confirmation.
- Do not expose secrets, tokens, cookies, private keys, personal data, or confidential business data.
- Do not copy third-party code or assets without license/provenance review.
- If validation is impossible, state why and provide a concrete manual verification path.
