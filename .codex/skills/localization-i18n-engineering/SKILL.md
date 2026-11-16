---
name: localization-i18n-engineering
description: "Use this skill for i18n architecture, locale routing, ICU messages, formatting, translation QA."
---

# Localization i18n Engineering

## Task Decisions

1. Define locale routing/fallback, translation keys and ICU plural/select behavior without concatenating translated fragments.
2. Test extraction, missing-key behavior, text expansion, RTL and timezone/currency formatting.

Use this skill for Programming tasks focused on i18n architecture, locale routing, ICU messages, formatting, translation QA.

## Guardrails

- Do not concatenate translated strings in ways that break grammar or RTL.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
