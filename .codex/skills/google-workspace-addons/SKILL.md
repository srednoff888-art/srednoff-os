---
name: google-workspace-addons
description: "Use this skill for Google Workspace add-ons, cards, manifests, OAuth scopes, Marketplace readiness."
---

# Google Workspace Addons

## Decisions

- Map host application, add-on lifecycle, manifest scopes, UI cards, and authorization flow.
- Keep external requests and user-data access scoped; handle missing authorization and host limitations.

## Acceptance

Validate manifest and test the real host flow with an approved test account.

## Constraints

- Do not request broad OAuth scopes without justification.
