---
name: docs-developer-portal-seo
description: "Use this skill for documentation SEO, version canonicals, API docs, examples, internal links, freshness."
---

# Docs Developer Portal SEO

## Task Decisions

1. Keep canonical/versioned documentation, code examples and navigation aligned with supported releases.
2. Check rendered API pages, duplicate version paths and broken example links without indexing private previews.

Use this skill for SEO tasks focused on documentation SEO, version canonicals, API docs, examples, internal links, freshness.

## Guardrails

- Do not remove old docs without redirect or version strategy.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
