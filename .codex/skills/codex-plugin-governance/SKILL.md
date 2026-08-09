---
name: codex-plugin-governance
description: Audit, install, update, share, or publish Codex plugins with provenance, dependency, permission, app-access, and supply-chain controls. Use for Agent Plugin manifests, plugin marketplaces or directories, workspace plugins, plugin bundles containing skills/MCP servers/apps/app templates/hooks/scripts, executor-provided skills, plugin permissions, refreshes, removals, or plugin publishing.
---

# Codex Plugin Governance

Treat a plugin as a versioned supply-chain bundle whose included capabilities may
have different trust, data, and action boundaries.

## Workflow

1. Identify the requested operation: inspect, install, update, enable, disable,
   remove, share, or publish. Keep install/update/publish as explicit user actions.
2. Record the exact source, publisher, repository, version or commit, license,
   release date, integrity evidence, support policy, and marketplace channel.
3. Inventory every bundled skill, MCP server, app, app template, hook, script,
   executable, network endpoint, and transitive dependency. Inspect plugin
   dependencies and app permissions with available plugin-management tools.
4. Classify each capability as read, write, admin, code execution, filesystem,
   browser, messaging, deployment, billing, production, or sensitive-data access.
   Required and optional apps remain separate decisions.
5. Verify layered authorization: workspace role, plugin availability, app access,
   app action controls, confirmation policy, OAuth scopes, source-system RBAC,
   sync boundaries, domain restrictions, and data residency.
6. Review untrusted content and execution paths for prompt injection, secret
   access, path traversal, arbitrary commands, mutable downloads, unsafe hooks,
   remote scripts, tool shadowing, and privilege escalation.
7. Prefer a pilot with read-only access, exact version pins, narrow scope, and a
   low-risk test. Require human confirmation before enabling write/admin actions.
8. For updates or marketplace refreshes, diff manifests, permissions,
   dependencies, scripts, endpoints, and bundled skills before acceptance. Keep a
   rollback path to the last trusted version.
9. For sharing or publishing, inspect the complete package, exclude secrets and
   machine-local state, validate licenses and metadata, then request explicit
   publication approval.
10. Report evidence, unresolved risks, granted authority, validation results, and
    the next confirmation boundary.

## Checklist

- Source and publisher are verified; no floating ref is trusted silently.
- Licenses cover every copied or redistributed skill, script, and asset.
- Required apps, optional apps, permissions, and source-system access are explicit.
- Executable hooks and scripts are opt-in, bounded, secret-safe, and reviewable.
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
- Do not publish secrets, tokens, cookies, private connector state, personal data,
  or machine-local configuration.
- Re-check current official Codex plugin and workspace documentation before
  high-impact recommendations.
