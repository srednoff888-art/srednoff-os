---
name: postgres-lock-budget-migrations
description: "Plan PostgreSQL schema or index changes with explicit lock, transaction and rollback budgets."
---

# Postgres Lock Budget Migrations

## Decisions And Evidence

1. Inspect relation size, blockers, target PostgreSQL version and deployment traffic before choosing an operation.
2. Test lock timeout, interrupted concurrent index creation and invalid-index cleanup in a representative disposable database.

## Boundary

Production execution and destructive cleanup require explicit approval; concurrent index operations have transaction restrictions.

## Source

[Current primary reference](https://www.postgresql.org/docs/current/sql-createindex.html). Check the installed version and current contract before execution.
