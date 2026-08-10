---
name: codex-plugin-governance
description: Audit, install, update, share, or publish Codex plugins with provenance, dependency, permission, app-access, and supply-chain controls. Use for portable Agent Plugins, local/personal/workspace/remote plugin catalogs, Agent Plugin manifests, marketplaces, plugin bundles containing skills/MCP servers/apps/app templates/hooks/scripts, executor-provided skills, plugin permissions, refreshes, removals, or publishing.
---

# Codex Plugin Governance

Treat a plugin as a versioned supply-chain bundle whose included capabilities may
have different trust, data, and action boundaries.

## Workflow

1. Identify the requested operation: inspect, install, update, enable, disable,
   remove, share, or publish. Keep install/update/publish as explicit user actions.
2. Identify whether discovery came from a local, personal, workspace, or remote
   catalog. Treat remote catalog metadata as untrusted until the exact artifact,
   publisher, repository, version or commit, license, release date, integrity
   evidence, support policy, and distribution channel are verified.
3. Inventory every bundled skill, MCP server, app, app template, hook, script,
   executable, network endpoint, and transitive dependency. Inspect plugin
   dependencies and app permissions with available plugin-management tools.
4. Validate the portable bundle boundary before loading it: reject absolute or
   parent-traversal paths, escaping symlinks, hidden executable payloads, and
   normalized skill/tool/app name collisions. Fail closed on ambiguous ownership.
5. Classify each capability as read, write, admin, code execution, filesystem,
   browser, messaging, deployment, billing, production, or sensitive-data access.
   Required and optional apps remain separate decisions.
6. Verify layered authorization: workspace role, plugin availability, app access,
   app action controls, confirmation policy, OAuth scopes, source-system RBAC,
   sync boundaries, domain restrictions, and data residency.
7. Review untrusted content and execution paths for prompt injection, secret
   access, path traversal, arbitrary commands, mutable downloads, unsafe hooks,
   remote scripts, tool shadowing, and privilege escalation.
8. Prefer a pilot with read-only access, exact version pins, narrow scope, and a
   low-risk test. Require human confirmation before enabling write/admin actions.
9. For updates or marketplace refreshes, diff manifests, permissions,
   dependencies, scripts, endpoints, and bundled skills before acceptance. Keep a
   rollback path to the last trusted version.
10. For sharing or publishing, inspect the complete package, exclude secrets and
   machine-local state, validate licenses and metadata, then request explicit
   publication approval.
11. Report evidence, unresolved risks, granted authority, validation results, and
    the next confirmation boundary.

## Checklist

- Source and publisher are verified; no floating ref is trusted silently.
- Licenses cover every copied or redistributed skill, script, and asset.
- Required apps, optional apps, permissions, and source-system access are explicit.
- Executable hooks and scripts are opt-in, bounded, secret-safe, and reviewable.
- Catalog source, resolved artifact identity, install timestamp, and content hash
  are recorded; catalog rank or installation history is not treated as trust.
- Bundle paths remain inside the verified root and capability names do not shadow
  host tools, other plugins, or security controls.
- Writes, sends, deploys, purchases, account changes, and destructive actions
  retain separate human confirmation.
- Update and rollback procedures are tested before broad rollout.

## Guardrails

- Do not install, update, enable, disable, remove, share, or publish a plugin when
  the user requested only review or research.
- Do not assume installing a plugin grants permission to its apps or underlying
  systems; preserve workspace and source-system authorization boundaries.
- Do not execute bundled remote scripts or hooks before the exact artifact and
  runtime boundary are trusted.
- Do not enable `--approve-for-me`, broad approval policies, or relaxed sandbox or
  network rules as a side effect of plugin installation or testing.
- Do not publish secrets, tokens, cookies, private connector state, personal data,
  or machine-local configuration.
- Re-check current official Codex plugin and workspace documentation before
  high-impact recommendations.
