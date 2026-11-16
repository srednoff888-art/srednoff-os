---
name: yandex-direct-feed-campaigns
description: Use for PPC work when Codex should validate feeds, offer data, policy risk, and measurement for Yandex ecommerce campaigns.
---

# yandex direct feed campaigns

## Task Decisions

1. Reconcile offer IDs, feed freshness, price/stock and landing variants with supported campaign/ad formats.
2. Classify moderation or eligibility failures before changing strategy or spend.

## Domain Focus

validate feeds, offer data, policy risk, and measurement for Yandex ecommerce campaigns.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
