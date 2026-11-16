---
name: sitemap-index-sharding
description: "Use this skill for large sitemap indexes, sharding, freshness, lastmod hygiene, monitoring, submission strategy."
---

# Sitemap Index Sharding

## Task Decisions

1. Group canonical indexable URLs into bounded sitemap files and a consistent index.
2. Validate XML, URL counts, lastmod provenance and fetchability without listing redirects, previews or missing pages.

Use this skill for SEO tasks focused on large sitemap indexes, sharding, freshness, lastmod hygiene, monitoring, submission strategy.

## Guardrails

- Do not include noindex, redirected, canonicalized-away, or error URLs in sitemaps.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
