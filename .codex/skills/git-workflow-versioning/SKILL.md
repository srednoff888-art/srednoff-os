---
name: git-workflow-versioning
description: "Use this skill for branches, commits, PR hygiene, changelog discipline, semantic versioning, release notes."
---

# Git Workflow Versioning

## Decisions

- Inspect branch, tracked changes, upstream state, and publication scope before staging.
- Commit only intended files; preserve user changes and avoid force operations unless requested.

## Acceptance

Review the staged diff, verify remote commit identity, and check required CI.

## Constraints

- Do not rewrite user history or discard user changes without explicit instruction.
