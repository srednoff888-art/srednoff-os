---
name: database-schema-migration-auditor
description: "Review a database migration for data loss, lock duration, backward compatibility, backfill behavior, and rollback feasibility."
---

# Database Schema Migration Auditor
Read the migration and its callers; identify affected tables, current versions, data volume, and concurrent writers.
## Decisions
- Prefer expand/migrate/contract sequencing for rolling deployments.
- Review generated drops/renames manually. Estimate locks and isolate long backfills from schema changes.
- Do not rewrite a migration already applied to shared environments.
## Acceptance
Rehearse against a scratch database with realistic constraints; test upgrade and rollback where reversible. Report irreversibility, lock assumptions, and untested production volume.
