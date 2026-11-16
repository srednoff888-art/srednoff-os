---
name: data-import-export-pipeline
description: "Use this skill for CSV/XLSX/JSON import/export, validation, preview, dedupe, rollback, audit logs."
---

# Data Import Export Pipeline

## Task Decisions

1. Define schema, encoding, locale, identifiers and row-level validation before committing imported records.
2. Preview errors and deduplication, test resumability and formula injection, and make partial success distinguishable from a complete import.

Use this skill for Programming tasks focused on CSV/XLSX/JSON import/export, validation, preview, dedupe, rollback, audit logs.

## Guardrails

- Do not bulk import, overwrite, or delete user data without explicit confirmation.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
