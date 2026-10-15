---
name: in-app-purchases-subscriptions
description: "Use this skill for IAP, subscriptions, entitlements, receipts, billing UX, app store policy."
---

# In App Purchases Subscriptions

## Decisions

- Model purchase, pending, renewal, refund, restore, expiry, and entitlement transitions.
- Verify receipts/server notifications and idempotent processing; keep price/provider data authoritative.

## Acceptance

Exercise sandbox purchase/restore/revocation and reconcile entitlements.

## Constraints

- Do not implement paid flows without clear refund, entitlement, and platform rules.
