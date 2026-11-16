---
name: meta-ads-catalog-dpa
description: Use for PPC work when Codex should validate Meta catalog, feed, event, availability, and dynamic product ad readiness.
---

# meta ads catalog dpa

## Task Decisions

1. Join catalog item IDs with website/app event content IDs, price, stock and variant URLs.
2. Test out-of-stock variants and stale feeds; do not diagnose an event-ID mismatch as creative fatigue.

## Domain Focus

validate Meta catalog, feed, event, availability, and dynamic product ad readiness.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
