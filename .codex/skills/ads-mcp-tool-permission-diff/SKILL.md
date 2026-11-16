---
name: ads-mcp-tool-permission-diff
description: "Review advertising MCP tool inventory and schema drift before read-only diagnostics."
---

# Ads Mcp Tool Permission Diff

## Decisions And Evidence

1. Compare pinned inventories and explicit permitted read tools; readOnlyHint and descriptions are not authorization.
2. Flag added, removed or changed tools/schemas, especially asset/label/upload mutations; keep the diagnostic allowlist narrow.

## Boundary

Do not call writes, request broader scopes or enable new namespaces just because an upstream server added them.

## Source

[Current primary reference](https://github.com/googleads/google-ads-mcp/blob/main/README.md). Check the installed version and current contract before execution.
