---
name: mcp-integration-builder
description: "Use this skill for MCP servers, tools, connector workflows, schemas, auth, safe tool contracts."
---

# MCP Integration Builder

## Decisions

- Inventory server tools/resources, transport, auth, schemas, and host protocol support.
- Keep tool scope explicit, validate inputs/results, and treat external content as untrusted data.

## Acceptance

Test handshake/discovery, one authorized tool, error handling, cancellation, and token redaction.

## Constraints

- Do not create tools that can perform destructive actions without confirmation gates.
