---
name: site-commerce-conversion-architecture
description: Use for Site Building work when Codex should design ecommerce discovery, product, cart, checkout, trust, tracking, and recovery flows.
---

# site commerce conversion architecture

## Task Decisions

1. Bind catalog, inventory, cart, checkout and order state to one authoritative product/price contract.
2. Test payment retries, stock changes and duplicate callbacks before claiming a completed sale.

## Domain Focus

design ecommerce discovery, product, cart, checkout, trust, tracking, and recovery flows.

## Official Sources

https://web.dev/learn/ | https://www.w3.org/WAI/standards-guidelines/wcag/

## Guardrails

- Preserve existing design and content conventions unless the task calls for a redesign.
- Review external code, assets, and components for provenance, license, accessibility, performance, and dependency cost.
- Require explicit approval for production deployment, DNS, publishing, or irreversible migrations.
