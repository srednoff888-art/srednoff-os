---
name: search-console-api-automation
description: "Use this skill for Search Console API exports, anomaly checks, page/query dashboards, automated diagnostics."
---

# Search Console API Automation

## Task Decisions

1. Pin property identity, date range, dimensions, aggregation and pagination before exporting.
2. Separate incomplete/fresh data and row limits from true zeros; retain query definitions for reconciliation.

Use this skill for SEO tasks focused on Search Console API exports, anomaly checks, page/query dashboards, automated diagnostics.

## Guardrails

- Do not expose query or performance data to unauthorized recipients.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
