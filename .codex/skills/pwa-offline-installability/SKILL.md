---
name: pwa-offline-installability
description: "Use this skill for PWA manifests, service workers, offline states, installability, caching strategy."
---

# PWA Offline Installability

## Decisions

- Define offline scope, service-worker update strategy, cache ownership, and install criteria.
- Avoid caching private responses or breaking network-required flows; expose stale/offline state.

## Acceptance

Test install, reload, version update, offline recovery, and logout cache behavior.

## Constraints

- Do not cache private or stale-sensitive data unsafely.
