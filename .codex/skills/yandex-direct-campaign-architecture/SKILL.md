---
name: yandex-direct-campaign-architecture
description: Use for PPC work when Codex should design Yandex Direct campaign, ad group, geo, audience, and naming architecture before build.
---

# yandex direct campaign architecture

## Task Decisions

1. Model campaign/ad-group boundaries around actual product, geography, targeting and conversion goals.
2. Validate EPK/v501 support and measurement before building; preserve history and avoid splitting solely for cosmetic naming.

## Domain Focus

design Yandex Direct campaign, ad group, geo, audience, and naming architecture before build.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
