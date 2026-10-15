---
name: playwright-mcp-visual-qa
description: "Use Playwright MCP for stateful browser inspection and responsive visual QA; prefer focused tests or CLI when they provide equivalent evidence."
---

# Playwright MCP Visual QA

Use the browser with the least privilege required for the test. Preserve a clear
boundary between local test environments and authenticated production accounts.

## Workflow

1. Confirm URL, environment, viewport/device matrix, test account scope, and
   whether the requested work is read-only.
2. Prefer isolated browser contexts, workspace-scoped files, explicit allowed
   hosts, and bounded output directories. Disable unnecessary capabilities.
3. Inspect semantic snapshots, screenshot key states when visual evidence is
   needed, and record console/network failures without leaking credentials.
4. Convert reproducible findings into project tests or snapshots; report visual
   differences, accessibility failures, and browser/session limitations.

## Guardrails

- Never enable unrestricted file access, unsandboxed browser execution, or
  shared authenticated profiles merely for convenience.
- Do not submit forms, publish content, purchase, or change account state
  without explicit user authorization.
- Use CLI plus focused tests rather than MCP when it is cheaper and equivalent.
