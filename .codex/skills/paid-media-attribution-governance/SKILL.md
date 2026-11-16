---
name: paid-media-attribution-governance
description: Use for PPC work when Codex should define cross-channel attribution, naming, UTMs, conversion ownership, consent, and reconciliation rules.
---

# paid media attribution governance

## Task Decisions

1. Document event/user/order/paid-sale definitions, attribution windows, timezone, currency and VAT basis.
2. Reconcile platform reports to CRM outcomes and mark unavailable joins as unavailable, never zero.

## Domain Focus

define cross-channel attribution, naming, UTMs, conversion ownership, consent, and reconciliation rules.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
