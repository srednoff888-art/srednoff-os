---
name: forms-checkout-ux
description: "Use this skill for forms, checkout flows, validation, error recovery, payment UX, friction reduction."
---

# Forms Checkout UX

## Decisions

- Define validation timing, payment state, retry behavior, and preservation of user input.
- Expose clear labels, totals, errors, and focus movement; prevent duplicate submission.

## Acceptance

Test failure/retry, keyboard flow, slow requests, and idempotent test payments.

## Constraints

- Do not collect unnecessary sensitive data.
