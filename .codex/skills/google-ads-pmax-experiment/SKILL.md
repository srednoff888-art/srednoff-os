---
name: google-ads-pmax-experiment
description: Use for PPC work when Codex should plan Google Performance Max experiments with asset, feed, goal, brand-safety, and incrementality controls.
---

# google ads pmax experiment

## Task Decisions

1. Isolate one asset/feed/goal change with a comparable baseline and an explicit learning/conversion-lag window.
2. Keep brand, inventory and measurement changes from confounding the result; spend changes remain approval-gated.

## Domain Focus

plan Google Performance Max experiments with asset, feed, goal, brand-safety, and incrementality controls.

## Official Sources

https://yandex.com/dev/direct/doc/en/ | https://developers.google.com/google-ads/api | https://developers.facebook.com/docs/marketing-apis

## Guardrails

- Start with read-only data and recommendations.
- Require explicit approval before changing spend, bids, audiences, ads, campaigns, or external account settings.
- Preserve campaign history and report the expected impact, rollback path, and measurement limitation.
