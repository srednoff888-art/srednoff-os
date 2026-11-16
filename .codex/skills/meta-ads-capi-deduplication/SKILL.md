---
name: meta-ads-capi-deduplication
description: Use for PPC work when Codex should design or review Meta Pixel and Conversions API event identity, deduplication, consent, and diagnostics.
---

# meta ads capi deduplication

## Task Decisions

1. Trace one business event through browser Pixel and server CAPI with stable shared event identity and matching event names.
2. Test retries, clock skew, consent denial and diagnostics using synthetic events; keep raw personal data out of logs.

## Domain Focus

design or review Meta Pixel and Conversions API event identity, deduplication, consent, and diagnostics.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
