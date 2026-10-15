---
name: firebase-app-backend
description: "Use this skill for Firebase Auth, Firestore, Functions, Storage, Hosting, app backend architecture."
---

# Firebase App Backend

## Decisions

- Map auth identity, data ownership, indexes, offline behavior, and required service APIs.
- Keep client/server trust boundaries explicit; test authorization rules independently of UI restrictions.

## Acceptance

Exercise authorized and unauthorized operations in emulators and validate deployment targets.

## Constraints

- Do not write insecure public rules or hardcode service credentials.
