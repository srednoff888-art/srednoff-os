---
name: site-production-launch-gate
description: Use for Site Building work when Codex should run site launch readiness across environment, redirects, analytics, forms, error monitoring, rollback, and ownership.
---

# site production launch gate

## Task Decisions

1. Verify production configuration, approved migrations, DNS/routes/assets, form delivery and observability.
2. Confirm public behavior after deploy and retain rollback evidence; build success alone is not launch success.

## Domain Focus

run site launch readiness across environment, redirects, analytics, forms, error monitoring, rollback, and ownership.

## Official Sources

https://web.dev/learn/ | https://www.w3.org/WAI/standards-guidelines/wcag/

## Guardrails

- Preserve existing design and content conventions unless the task calls for a redesign.
- Review external code, assets, and components for provenance, license, accessibility, performance, and dependency cost.
- Require explicit approval for production deployment, DNS, publishing, or irreversible migrations.
