---
name: seo-change-impact-monitoring
description: Use for SEO work when Codex should measure SEO release impact with pre/post baselines, annotations, crawl checks, and rollback criteria.
---

# seo change impact monitoring

## Task Decisions

1. Record the exact changed URL cohort, deployment time and expected crawl/index delay.
2. Compare coverage, search and conversion effects with controls; keep unrelated site changes out of the causal claim.

## Domain Focus

measure SEO release impact with pre/post baselines, annotations, crawl checks, and rollback criteria.

## Official Sources

https://developers.google.com/search/docs | https://schema.org/docs/gs.html

## Guardrails

- Capture baselines before making recommendations that affect crawl, indexation, or traffic.
- Do not delete pages, publish redirects, change robots, or alter canonicals without explicit approval.
- Separate observed evidence from inferred search-impact estimates.
