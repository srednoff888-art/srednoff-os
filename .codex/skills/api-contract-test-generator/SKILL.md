---
name: api-contract-test-generator
description: "Use this skill for OpenAPI, JSON schema, typed clients, contract tests, compatibility assertions."
---

# API Contract Test Generator

## Task Decisions

1. Derive request/response cases from the pinned schema, including null versus missing, pagination, validation and compatibility boundaries.
2. Test both producer and consumer behavior; do not update golden snapshots simply to accept an unexpected API change.

Use this skill for Programming tasks focused on OpenAPI, JSON schema, typed clients, contract tests, compatibility assertions.

## Guardrails

- Do not generate tests that assert stale or undocumented behavior as a contract.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
