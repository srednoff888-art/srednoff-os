---
name: google-ads-mcp-reporting
description: "Use the official Google Ads MCP tools for authorized read-only account discovery, resource metadata, GAQL reporting, and campaign diagnostics."
---

# Google Ads MCP Reporting

Confirm the approved account scope, manager/customer relationship, date range, timezone, currency, and conversion definitions.
## Decisions
- Use accessible-customer discovery and resource metadata to construct valid queries rather than guessing version-specific fields.
- Keep credentials in the existing secure configuration. Request only the fields needed for the diagnostic and account scope.
- Separate reporting delay, conversion lag, missing rows, and true zeros. Reconcile metrics to campaign configuration and landing pages.
## Acceptance
Record query shape, account scope without secret values, reporting period, completeness, and observations. A reporting MCP does not imply permission or support for campaign writes; report recommendations as drafts unless an explicit requested execution path exists.
