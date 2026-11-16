---
name: google-ads-shopping-feed-health
description: Use for PPC work when Codex should review Shopping feed quality, product eligibility, price availability, taxonomy, and landing alignment.
---

# google ads shopping feed health

## Task Decisions

1. Reconcile item identifiers, price, availability, landing variants and disapproval reasons across feed and store.
2. Separate product eligibility defects from bidding or attribution problems before recommending campaign changes.

## Domain Focus

review Shopping feed quality, product eligibility, price availability, taxonomy, and landing alignment.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
