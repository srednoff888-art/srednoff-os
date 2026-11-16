---
name: google-ads-conversion-quality
description: Use for PPC work when Codex should validate Google Ads conversion actions, enhanced conversions, consent, values, deduplication, and import quality.
---

# google ads conversion quality

## Task Decisions

1. Reconcile action purpose, primary/secondary status, value/currency, consent and duplicate event identity against the business outcome.
2. Check current Data Manager eligibility before implementing offline imports; an accepted upload is not proof of attribution.

## Domain Focus

validate Google Ads conversion actions, enhanced conversions, consent, values, deduplication, and import quality.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
