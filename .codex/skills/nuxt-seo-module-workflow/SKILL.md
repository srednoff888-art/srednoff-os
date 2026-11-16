---
name: nuxt-seo-module-workflow
description: "Use this skill for Nuxt SEO modules, sitemap, robots, schema, OG images, i18n SEO."
---

# Nuxt SEO Module Workflow

## Task Decisions

1. Inspect installed Nuxt/module versions and resolve metadata, canonical, sitemap and prerender settings together.
2. Crawl the production output and dynamic routes; plugin registration alone does not prove generated SEO tags.

Use this skill for SEO tasks focused on Nuxt SEO modules, sitemap, robots, schema, OG images, i18n SEO.

## Guardrails

- Do not rely on module defaults without checking generated output.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
