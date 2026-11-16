---
name: meta-ads-policy-risk-gate
description: Use for PPC work when Codex should check Meta policy, restricted content, personal-attribute language, landing, and account-risk signals.
---

# meta ads policy risk gate

## Task Decisions

1. Review actual creative text, targeting context, product restrictions and landing experience under current Meta policy.
2. Flag personal-attribute implications and unsupported claims without promising moderation approval.

## Domain Focus

check Meta policy, restricted content, personal-attribute language, landing, and account-risk signals.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
