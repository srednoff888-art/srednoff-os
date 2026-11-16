---
name: admin-crud-ux-patterns
description: "Use this skill for admin CRUD flows, bulk actions, confirmations, auditability, permissions, recovery."
---

# Admin Crud UX Patterns

## Task Decisions

1. Keep permission checks authoritative on the server and make selection scope explicit for filtered, paginated and bulk operations.
2. Test partial batch failure, stale records, double submission and recovery without losing entered data.

Use this skill for Web Design tasks focused on admin CRUD flows, bulk actions, confirmations, auditability, permissions, recovery.

## Guardrails

- Do not make destructive admin actions one-click without clear confirmation.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
