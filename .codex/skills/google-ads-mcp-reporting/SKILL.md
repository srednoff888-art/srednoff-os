---
name: google-ads-mcp-reporting
description: "Use the official Google Ads MCP tools for authorized read-only account discovery, resource metadata, GAQL reporting, and campaign diagnostics."
---

# Google Ads MCP Reporting

Confirm the approved account scope, manager/customer relationship, date range, timezone, currency, and conversion definitions.
## Decisions
- Use accessible-customer discovery and resource metadata to construct valid queries rather than guessing version-specific fields.
- Inventory actual tools before connecting: current upstream also includes asset, label and upload mutations. For a reporting deployment explicitly disable `labels` and `assets` namespaces in the pinned `tools_config.yaml`; do not rely on bundled defaults.
- Keep the diagnostic allowlist to reviewed discovery/search/metadata tools. Compare inventory/schema changes with `scripts/mcp_capability_diff.py`; a `readOnlyHint` is not authorization or a security boundary.
- Keep credentials in the existing secure configuration. Request only the fields needed for the diagnostic and account scope.
- Separate reporting delay, conversion lag, missing rows, and true zeros. Reconcile metrics to campaign configuration and landing pages.
## Acceptance
Record query shape, account scope without secret values, reporting period, completeness, and observations. A reporting MCP does not imply permission or support for campaign writes; report recommendations as drafts unless an explicit requested execution path exists.

[Current upstream tool/config contract](https://github.com/googleads/google-ads-mcp/blob/main/README.md). Rechecked 2026-11-16; no advertising account was connected.
