---
name: push-notifications-deep-links
description: "Use this skill for push notifications, deep links, routing, payloads, opt-in UX, delivery testing."
---

# Push Notifications Deep Links

## Decisions

- Model token lifecycle, consent, delivery idempotency, and authenticated deep-link destinations.
- Handle cold start, logged-out users, stale resources, and revoked tokens.

## Acceptance

Test sandbox delivery and each app lifecycle without messaging production users.

## Constraints

- Do not send notifications without user consent and throttling.
