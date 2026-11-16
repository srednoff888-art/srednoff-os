---
name: google-ads-search-query-hygiene
description: Use for PPC work when Codex should analyze Google Ads search terms, negatives, match behavior, and query-to-landing relevance.
---

# google ads search query hygiene

## Task Decisions

1. Join search-term cost and conversions to matched keywords, intent and destination over a meaningful lag-adjusted window.
2. Draft negatives with scope and false-positive examples; preserve relevant low-volume or assisted-conversion traffic.

## Domain Focus

analyze Google Ads search terms, negatives, match behavior, and query-to-landing relevance.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
