---
name: javascript-seo-rendering
description: "Use this skill for JavaScript SEO, SSR/SSG, rendered DOM, crawler limitations, hydration and indexing issues."
---

# Javascript SEO Rendering

## Task Decisions

1. Compare initial HTML, rendered DOM and crawler-visible status/links/metadata for representative routes.
2. Separate hydration errors from indexing and demand; validate the production build instead of assuming browser visibility means indexability.

Use this skill for SEO tasks focused on JavaScript SEO, SSR/SSG, rendered DOM, crawler limitations, hydration and indexing issues.

## Guardrails

- Do not assume search crawlers see client-rendered content correctly.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
