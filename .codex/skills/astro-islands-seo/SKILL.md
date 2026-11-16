---
name: astro-islands-seo
description: "Use this skill for Astro static output, islands hydration, content collections, CWV, schema and metadata."
---

# Astro Islands SEO

## Task Decisions

1. Check prerendered HTML for the important content, metadata and links before islands hydrate.
2. Validate locale/canonical generation and one representative interactive island without shipping unrelated client JavaScript.

Use this skill for SEO tasks focused on Astro static output, islands hydration, content collections, CWV, schema and metadata.

## Guardrails

- Do not hydrate content that can remain static for SEO and performance.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
