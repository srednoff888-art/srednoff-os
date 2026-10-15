---
name: firebase-auth-security-rules
description: "Use this skill for Firebase security rules, auth claims, emulator tests, least privilege access."
---

# Firebase Auth Security Rules

## Decisions

- Model ownership and tenant scope for each collection/storage path before changing rules.
- Deny unintended public reads/writes and avoid relying on client-provided role fields.

## Acceptance

Run emulator tests for cross-user, cross-tenant, unauthenticated, and allowed requests.

## Constraints

- Do not deploy permissive rules to production without explicit review.
