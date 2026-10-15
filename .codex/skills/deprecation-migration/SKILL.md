---
name: deprecation-migration
description: "Use this skill for dependency upgrades, SDK migrations, breaking changes, compatibility plans, rollback."
---

# Deprecation Migration

## Decisions

- Inventory deprecated calls and consumers against the official replacement contract and supported versions.
- Stage compatibility changes and data transformations; keep rollback until new behavior is verified.

## Acceptance

Run old/new contract cases and report remaining deprecated paths explicitly.

## Constraints

- Do not migrate production-critical systems without reading release notes or docs.
