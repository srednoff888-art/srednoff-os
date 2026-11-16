---
name: seo-log-file-crawl-analysis
description: Use for SEO work when Codex should analyze crawler logs for crawl waste, status patterns, bot access, rendering, and indexability evidence.
---

# seo log file crawl analysis

## Task Decisions

1. Verify bot identity and inspect repeated status, latency and waste patterns by URL class.
2. Use log evidence alongside indexing data; a frequently crawled URL is not necessarily valuable or indexed.

## Domain Focus

analyze crawler logs for crawl waste, status patterns, bot access, rendering, and indexability evidence.

## Official Sources

https://developers.google.com/search/docs | https://schema.org/docs/gs.html

## Guardrails

- Capture baselines before making recommendations that affect crawl, indexation, or traffic.
- Do not delete pages, publish redirects, change robots, or alter canonicals without explicit approval.
- Separate observed evidence from inferred search-impact estimates.
