---
name: canonical-redirect-audit
description: "Use this skill for canonical tags, redirects, duplicates, status codes, consolidation, migration safety."
---

# Canonical Redirect Audit

## Task Decisions

1. Compare status, canonical, sitemap, internal links and rendered locale for each URL cluster.
2. Check redirect chains and soft-404 behavior; canonical tags are hints and must not contradict the chosen indexable destination.

Use this skill for SEO tasks focused on canonical tags, redirects, duplicates, status codes, consolidation, migration safety.

## Guardrails

- Do not canonicalize pages with meaningfully different user intent.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
