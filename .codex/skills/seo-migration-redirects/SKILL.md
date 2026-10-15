---
name: seo-migration-redirects
description: "Use this skill for site migrations, redirect maps, canonical preservation, launch QA, traffic risk mitigation."
---

# SEO Migration Redirects

## Decisions

- Inventory old URLs, intended replacements, traffic/link value, and canonical/indexing behavior.
- Use direct relevant redirects, prevent loops/chains, and preserve query/path semantics where needed.

## Acceptance

Test representative URL pairs, sitemap/internal links, and post-release monitoring.

## Constraints

- Do not ship URL migrations without rollback and monitoring plans.
