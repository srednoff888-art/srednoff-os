---
name: site-platform-architecture
description: Use for Site Building work when Codex should choose site architecture, rendering, hosting, CMS, integrations, and performance boundaries from product evidence.
---

# site platform architecture

## Task Decisions

1. Choose rendering, CMS, auth and deployment boundaries from the actual content/change/traffic requirements.
2. Document the simplest viable integration and its failure/rollback paths rather than introducing speculative infrastructure.

## Domain Focus

choose site architecture, rendering, hosting, CMS, integrations, and performance boundaries from product evidence.

## Official Sources

https://web.dev/learn/ | https://www.w3.org/WAI/standards-guidelines/wcag/

## Guardrails

- Preserve existing design and content conventions unless the task calls for a redesign.
- Review external code, assets, and components for provenance, license, accessibility, performance, and dependency cost.
- Require explicit approval for production deployment, DNS, publishing, or irreversible migrations.
