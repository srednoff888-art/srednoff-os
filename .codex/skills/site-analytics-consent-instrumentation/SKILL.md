---
name: site-analytics-consent-instrumentation
description: Use for Site Building work when Codex should implement consent-aware analytics events, data layer, attribution, QA, and privacy-safe observability.
---

# site analytics consent instrumentation

## Task Decisions

1. Define event names, payload contracts, consent states and the analytics-versus-CRM business metric.
2. Test denied/granted/withdrawn paths and duplicate event prevention without sending real personal data in test fixtures.

## Domain Focus

implement consent-aware analytics events, data layer, attribution, QA, and privacy-safe observability.

## Official Sources

https://web.dev/learn/ | https://www.w3.org/WAI/standards-guidelines/wcag/

## Guardrails

- Preserve existing design and content conventions unless the task calls for a redesign.
- Review external code, assets, and components for provenance, license, accessibility, performance, and dependency cost.
- Require explicit approval for production deployment, DNS, publishing, or irreversible migrations.
