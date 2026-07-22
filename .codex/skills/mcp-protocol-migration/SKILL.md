---
name: mcp-protocol-migration
description: Audit, plan, implement, or review Model Context Protocol version and SDK migrations. Use for MCP 2026-07-28, stateless Streamable HTTP, server/discover, removal of initialize or Mcp-Session-Id, MCP Tasks extension changes, full JSON Schema 2020-12 tool schemas, OAuth issuer hardening, deprecated roots/sampling/logging, or cross-version client/server compatibility.
---

# MCP Protocol Migration

Migrate MCP clients and servers with explicit compatibility, rollout, and rollback gates.

## Workflow

1. Inventory the current protocol version, SDK/language, transport, client and server versions, extensions, auth flow, and production topology.
2. Read the target specification changelog plus the exact SDK migration guide and release notes. Treat RC, beta, and pre-release packages as opt-in only; pin exact versions.
3. Build a compatibility matrix for old client/new server, new client/old server, and new client/new server. Verify version negotiation rather than assuming simultaneous upgrades.
4. Map wire and lifecycle changes before editing code: handshake/discovery, session state, routing headers, server-to-client requests, subscriptions, caching, tracing, tasks, errors, and schemas.
5. Move hidden protocol session state to explicit tool arguments or durable application storage when the target protocol is stateless. Do not expose secrets or authorization state as model-visible handles.
6. Update auth and validation boundaries: issuer checks, client registration binding, scopes, redirect URIs, schema depth/time limits, external `$ref` policy, and request/header consistency.
7. Run official conformance tests when available, then add project fixtures for mixed versions, cancellation, retries, cache expiry, long-running tasks, and rollback.
8. Roll out behind an explicit version/feature gate, observe failures and latency, and keep the previous stable path until evidence supports removal.

## 2026-07-28 Gate

- Replace Streamable HTTP `initialize`/`initialized` and `Mcp-Session-Id` assumptions with per-request metadata and `server/discover` where supported.
- Require and validate `Mcp-Method` and `Mcp-Name`; reject disagreement with the JSON-RPC body.
- Model multi-round-trip input as `InputRequiredResult` plus replayed state instead of free-floating server requests.
- Migrate experimental core Tasks to the Tasks extension; do not depend on removed `tasks/list`.
- Honor `ttlMs` and `cacheScope`; propagate W3C trace context without logging secrets or personal data.
- Treat roots, sampling, and logging as deprecated but not immediately removed; plan replacements without breaking older peers.
- Validate full JSON Schema 2020-12 with bounded depth and time, and never auto-fetch external `$ref` targets.

## Checklist

- Target spec and SDK versions are exact and source-linked.
- Stable and pre-release dependencies are not mixed accidentally.
- Compatibility, conformance, rollback, and observability evidence exists.
- Destructive tools still require explicit human approval after migration.
- Production rollout or package publication has separate user authorization.

## Guardrails

- Do not upgrade production, publish packages, rotate credentials, or remove the old protocol path without explicit approval.
- Do not claim RC/beta behavior is final; re-check official release notes before implementation.
- Do not infer SDK support from the specification alone; verify the selected language SDK and client host independently.
- Do not copy examples from repositories with unclear or incompatible licenses.
