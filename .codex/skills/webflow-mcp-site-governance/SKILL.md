---
name: webflow-mcp-site-governance
description: Use when a Webflow site, CMS, Designer context, components, styles, pages, assets, or variables must be inspected or changed through Webflow MCP. Keep discovery read-only first and require explicit approval before any mutation or publish action.
---

# Webflow MCP Site Governance

Treat Webflow MCP as an account-connected authoring surface, not a local code
generator. Confirm the target workspace, site, locale, staging/production
boundary, and allowed write scope before invoking a mutating tool.

## Workflow

1. Inventory available sites, collections, styles, components, variables, and
   Designer context without changing state.
2. Map a requested change to the smallest affected Webflow objects and capture
   their current values plus a rollback plan.
3. Obtain explicit approval for creates, updates, deletes, publishes, asset
   uploads, or CMS content changes.
4. Make bounded changes, re-read the affected objects, and report the IDs,
   scope, validation, and unresolved publication state without exposing tokens.

## Guardrails

- Do not install a bridge app, create API tokens, publish a Designer extension,
  or alter a live site without the user's explicit confirmation.
- Keep CMS writes, design-system changes, and publication as separate approval
  boundaries.
- Use the official Webflow MCP server/docs; do not run third-party bridge code
  until its source, version, and permissions have been reviewed.
