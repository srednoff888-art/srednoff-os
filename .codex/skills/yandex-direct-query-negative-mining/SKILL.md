---
name: yandex-direct-query-negative-mining
description: Use for PPC work when Codex should analyze Yandex search queries, negatives, match intent, and preserve valuable traffic.
---

# yandex direct query negative mining

## Task Decisions

1. Join query intent with spend, lag-adjusted conversions and landing relevance before proposing negatives.
2. Return scoped drafts with valuable-query counterexamples and apply only after an explicit approved change.

## Domain Focus

analyze Yandex search queries, negatives, match intent, and preserve valuable traffic.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
