---
name: site-commerce-conversion-architecture
description: Use for Site Building work when Codex should design ecommerce discovery, product, cart, checkout, trust, tracking, and recovery flows.
---

# site commerce conversion architecture

## Workflow

1. Confirm the business outcome, owner, source data, constraints, and success metric.
2. Inspect the project and available account or analytics evidence before proposing changes.
3. Use official documentation for current platform behavior and retain source provenance.
4. Produce an evidence-backed plan with assumptions, dependencies, and measurable validation.
5. Run only read-only diagnostics by default; gate external, paid, production, or publishing actions behind explicit approval.

## Domain Focus

design ecommerce discovery, product, cart, checkout, trust, tracking, and recovery flows.

## Official Sources

https://web.dev/learn/ | https://www.w3.org/WAI/standards-guidelines/wcag/

## Guardrails

- Preserve existing design and content conventions unless the task calls for a redesign.
- Review external code, assets, and components for provenance, license, accessibility, performance, and dependency cost.
- Require explicit approval for production deployment, DNS, publishing, or irreversible migrations.