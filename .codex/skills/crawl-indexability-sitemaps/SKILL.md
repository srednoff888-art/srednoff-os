---
name: crawl-indexability-sitemaps
description: "Use this skill for robots.txt, XML sitemaps, canonicalization, redirects, crawl budget, noindex issues."
---

# Crawl Indexability Sitemaps

## Decisions

- Reconcile sitemap URLs with status, redirects, canonical targets, robots directives, and rendered content.
- Sample each template and exclude noncanonical, blocked, or unavailable pages from proposed sitemap changes.

## Acceptance

Report contradictions by URL with the exact crawl observation and verification command.

## Constraints

- Do not block important pages without explaining the consequence.
