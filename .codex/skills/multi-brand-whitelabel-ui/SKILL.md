---
name: multi-brand-whitelabel-ui
description: "Use this skill for white-label UI, brand tokens, tenant themes, preview workflows, theme isolation."
---

# Multi Brand Whitelabel UI

## Task Decisions

1. Separate brand tokens/assets from product behavior and tenant authorization.
2. Test missing brand config, contrast and asset fallbacks without allowing a theme key to select another tenant's data.

Use this skill for Web Design tasks focused on white-label UI, brand tokens, tenant themes, preview workflows, theme isolation.

## Guardrails

- Do not leak brand assets or settings across tenants.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
