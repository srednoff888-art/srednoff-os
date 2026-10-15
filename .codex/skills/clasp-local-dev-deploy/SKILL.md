---
name: clasp-local-dev-deploy
description: "Use this skill for clasp workflows, Apps Script local development, manifests, deployments, versioning."
---

# Clasp Local Dev Deploy

## Decisions

- Confirm script ID, local source root, manifest, scopes, and deployment/version targets.
- Keep push, version creation, and deployment updates separate; preserve current deployment identity.

## Acceptance

Inspect the deployment and exercise an approved test function after a scoped update.

## Constraints

- Do not overwrite remote script projects without checking local/remote state.
