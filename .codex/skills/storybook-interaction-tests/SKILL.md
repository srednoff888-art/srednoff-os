---
name: storybook-interaction-tests
description: "Use this skill for Storybook play functions, interaction tests, component states, accessibility checks."
---

# Storybook Interaction Tests

## Task Decisions

1. Exercise component play states with realistic providers, focus and async data boundaries.
2. Assert user-visible outcomes and inspect visual states; isolated stories do not validate full-page integration.

Use this skill for Web Design tasks focused on Storybook play functions, interaction tests, component states, accessibility checks.

## Guardrails

- Do not add stories that cannot run in CI or local review.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
