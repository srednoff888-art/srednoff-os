---
name: site-api-integration-boundaries
description: Use for Site Building work when Codex should design resilient site API integration boundaries, failure states, caching, secrets, and contract tests.
---

# site api integration boundaries

## Task Decisions

1. Keep browser-safe and server-only credentials/data contracts separated and validate untrusted responses.
2. Test timeout, schema drift and partial failure; do not expose privileged upstream APIs through a generic proxy.

## Domain Focus

design resilient site API integration boundaries, failure states, caching, secrets, and contract tests.

## Official Sources

https://web.dev/learn/ | https://www.w3.org/WAI/standards-guidelines/wcag/

## Guardrails

- Preserve existing design and content conventions unless the task calls for a redesign.
- Review external code, assets, and components for provenance, license, accessibility, performance, and dependency cost.
- Require explicit approval for production deployment, DNS, publishing, or irreversible migrations.
