---
name: yandex-direct-goal-attribution
description: Use for PPC work when Codex should validate Yandex Metrica goals, attribution, offline conversion evidence, and reporting joins.
---

# yandex direct goal attribution

## Task Decisions

1. Validate goal identity, attribution model, timezone and joins from Direct through Metrica to qualified/paid outcomes.
2. Treat absent ecommerce/CDP/CRM coverage as unavailable, not zero; do not replace task-specific economics with generic ROAS targets.

## Domain Focus

validate Yandex Metrica goals, attribution, offline conversion evidence, and reporting joins.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
