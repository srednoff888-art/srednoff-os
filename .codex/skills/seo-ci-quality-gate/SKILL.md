---
name: seo-ci-quality-gate
description: "Use this skill for SEO checks in CI, metadata, canonicals, links, robots, sitemap, noindex regressions."
---

# SEO CI Quality Gate

## Task Decisions

1. Check generated metadata, canonical, index directives, sitemap URLs and internal links in a deterministic build.
2. Keep live-network checks isolated from blocking local tests and verify both an indexable page and a protected preview.

Use this skill for SEO tasks focused on SEO checks in CI, metadata, canonicals, links, robots, sitemap, noindex regressions.

## Guardrails

- Do not make CI flaky with network-only SEO checks unless isolated.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
