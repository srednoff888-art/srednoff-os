---
name: seo-search-intent-clustering
description: Use for SEO work when Codex should cluster keywords by intent, entity, funnel, SERP shape, and page ownership without cannibalization.
---

# seo search intent clustering

## Task Decisions

1. Cluster queries by the user task and likely destination, preserving ambiguous and mixed-intent cases.
2. Validate a sample against current SERPs and map each cluster to a canonical page rather than generating duplicates.

## Domain Focus

cluster keywords by intent, entity, funnel, SERP shape, and page ownership without cannibalization.

## Official Sources

https://developers.google.com/search/docs | https://schema.org/docs/gs.html

## Guardrails

- Capture baselines before making recommendations that affect crawl, indexation, or traffic.
- Do not delete pages, publish redirects, change robots, or alter canonicals without explicit approval.
- Separate observed evidence from inferred search-impact estimates.
