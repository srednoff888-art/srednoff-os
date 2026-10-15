---
name: playwright-cli-task-workflow
description: "Use the installed Playwright CLI for bounded browser tasks, screenshots, selectors, and reusable tests when that interface fits the available environment."
---

# Playwright CLI Task Workflow

Inspect the installed CLI version and help before using flags. Prefer the environment's purpose-built browser tools when they provide the required workflow.
## Decisions
- Keep a dedicated test session and explicit URL/account scope. Read current snapshots before referring to element identifiers.
- Store screenshots/traces as artifacts and inspect only relevant sections of large snapshots.
- Convert a confirmed defect into the project's existing Playwright tests; do not rely solely on an exploratory CLI session.
## Acceptance
Exercise the requested path and its failure state, capture the relevant viewport evidence, and close task-owned browser sessions. Keep purchases, messages, submissions, and account writes within the user's requested scope.
