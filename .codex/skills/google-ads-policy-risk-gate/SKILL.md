---
name: google-ads-policy-risk-gate
description: Use for PPC work when Codex should check Google Ads policy, API constraints, landing experience, and approval risk before changes.
---

# google ads policy risk gate

## Workflow

1. Confirm the business outcome, owner, source data, constraints, and success metric.
2. Inspect the project and available account or analytics evidence before proposing changes.
3. Use official documentation for current platform behavior and retain source provenance.
4. Produce an evidence-backed plan with assumptions, dependencies, and measurable validation.
5. Run only read-only diagnostics by default; gate external, paid, production, or publishing actions behind explicit approval.

## Domain Focus

check Google Ads policy, API constraints, landing experience, and approval risk before changes.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.