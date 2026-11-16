---
name: checkout-trust-risk-ux
description: "Use this skill for checkout trust, fraud friction, payment clarity, policies, risk-reducing UX."
---

# Checkout Trust Risk UX

## Task Decisions

1. Expose the final price, shipping, recurring terms and recoverable payment errors before authorization.
2. Test interrupted checkout, repeated submission and declined payment without concealing fees or bypassing risk controls.

Use this skill for Web Design tasks focused on checkout trust, fraud friction, payment clarity, policies, risk-reducing UX.

## Guardrails

- Do not add dark patterns or obscure billing terms.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
