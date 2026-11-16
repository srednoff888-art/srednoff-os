---
name: paid-media-budget-pacing
description: Use for PPC work when Codex should analyze paid-media budget pacing, caps, marginal efficiency, and safe reallocation proposals.
---

# paid media budget pacing

## Task Decisions

1. Reconcile actual spend, reporting lag, remaining period and approved caps before projecting pacing.
2. Draft bounded changes with a stop condition and rollback; projected underdelivery alone is not permission to raise spend.

## Domain Focus

analyze paid-media budget pacing, caps, marginal efficiency, and safe reallocation proposals.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
