---
name: yandex-direct-bid-strategy-review
description: Use for PPC work when Codex should review Yandex Direct bidding, learning constraints, conversion volume, and guardrails before bid changes.
---

# yandex direct bid strategy review

## Task Decisions

1. Inspect the actual strategy, learning constraints, target definitions, conversion quality and approved economics.
2. Draft one bounded change with a stop window and rollback; low conversion volume alone is not permission to increase bids.

## Domain Focus

review Yandex Direct bidding, learning constraints, conversion volume, and guardrails before bid changes.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
