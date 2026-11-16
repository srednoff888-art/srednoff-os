---
name: google-ads-policy-risk-gate
description: Use for PPC work when Codex should check Google Ads policy, API constraints, landing experience, and approval risk before changes.
---

# google ads policy risk gate

## Task Decisions

1. Check the current policy for the actual product, claim, destination and market, plus account-level restrictions.
2. Return evidence and a publication gate; passing a local checklist does not guarantee platform approval.

## Domain Focus

check Google Ads policy, API constraints, landing experience, and approval risk before changes.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
