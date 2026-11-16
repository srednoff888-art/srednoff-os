---
name: headless-component-composition
description: "Use this skill for accessible unstyled components, composition patterns, controlled/uncontrolled state, styling freedom."
---

# Headless Component Composition

## Task Decisions

1. Assign controlled/uncontrolled state ownership and preserve the headless primitive's semantic and focus contracts.
2. Test composed slots, disabled/error variants and keyboard behavior before adding styling abstractions.

Use this skill for Web Design tasks focused on accessible unstyled components, composition patterns, controlled/uncontrolled state, styling freedom.

## Guardrails

- Do not rebuild complex accessibility primitives when a proven primitive exists.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
