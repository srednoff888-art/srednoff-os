---
name: site-content-model-cms
description: Use for Site Building work when Codex should design content types, editorial workflows, previews, localization, permissions, and migration-safe CMS models.
---

# site content model cms

## Task Decisions

1. Model actual editorial entities, references, locales and publication states before choosing CMS primitives.
2. Test preview authorization, rich-text sanitization and migration of existing entries.

## Domain Focus

design content types, editorial workflows, previews, localization, permissions, and migration-safe CMS models.

## Official Sources

https://web.dev/learn/ | https://www.w3.org/WAI/standards-guidelines/wcag/

## Guardrails

- Preserve existing design and content conventions unless the task calls for a redesign.
- Review external code, assets, and components for provenance, license, accessibility, performance, and dependency cost.
- Require explicit approval for production deployment, DNS, publishing, or irreversible migrations.
