---
name: node-package-release-engineering
description: "Use this skill for npm package exports, ESM/CJS compatibility, semantic versioning, release automation, changelogs."
---

# Node Package Release Engineering

## Task Decisions

1. Inspect package exports, included files, supported Node versions and source/type artifacts before publish.
2. Validate a packed tarball in a clean consumer and use approved provenance/publish identity; do not publish during a dry run.

Use this skill for Programming tasks focused on npm package exports, ESM/CJS compatibility, semantic versioning, release automation, changelogs.

## Guardrails

- Do not publish or tag releases without explicit confirmation.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
