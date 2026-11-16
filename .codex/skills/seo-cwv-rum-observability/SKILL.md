---
name: seo-cwv-rum-observability
description: Use for SEO work when Codex should connect Core Web Vitals lab data, RUM, releases, templates, and SEO impact triage.
---

# seo cwv rum observability

## Task Decisions

1. Segment field LCP/INP/CLS by page/device and reconcile with lab traces from the same user journey.
2. Report sample/window limitations and diagnose the element/event responsible before proposing a performance change.

## Domain Focus

connect Core Web Vitals lab data, RUM, releases, templates, and SEO impact triage.

## Official Sources

https://developers.google.com/search/docs | https://schema.org/docs/gs.html

## Guardrails

- Capture baselines before making recommendations that affect crawl, indexation, or traffic.
- Do not delete pages, publish redirects, change robots, or alter canonicals without explicit approval.
- Separate observed evidence from inferred search-impact estimates.
