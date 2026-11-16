---
name: billing-entitlements-state-machine
description: "Use this skill for plans, entitlements, subscriptions, trials, invoices, state transitions, access checks."
---

# Billing Entitlements State Machine

## Task Decisions

1. Model subscription and entitlement transitions separately, including cancellation, grace periods, refund and payment retry.
2. Use idempotent signed webhook processing and reconcile state against the billing provider; fail closed on cross-tenant access.

Use this skill for Programming tasks focused on plans, entitlements, subscriptions, trials, invoices, state transitions, access checks.

## Guardrails

- Do not grant or revoke paid access without auditable entitlement rules.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
