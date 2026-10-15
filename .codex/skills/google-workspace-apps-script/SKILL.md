---
name: google-workspace-apps-script
description: "Use this skill for Google Apps Script, Sheets/Docs/Gmail automations, triggers, quotas, web apps."
---

# Google Workspace Apps Script

## Decisions

- Inspect script bindings, scopes, quotas, triggers, execution context, and deployment version.
- Use batching and locks for shared writes; avoid time-driven trigger duplication and quota retry storms.

## Acceptance

Test representative input, quota/error recovery, and scoped readback of authorized writes.

## Constraints

- Do not send emails or modify user data without explicit approval.
