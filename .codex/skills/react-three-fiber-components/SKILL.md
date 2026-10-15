---
name: react-three-fiber-components
description: "Use this skill for React Three Fiber components, hooks, suspense, drei helpers, declarative 3D UI."
---

# React Three Fiber Components

## Decisions

- Keep scene state and React state ownership explicit; use frame loops only for continuous animation.
- Dispose replaced assets, avoid per-frame React updates, and profile draw calls/DPR.

## Acceptance

Validate controls, load failures, screenshots, and mobile frame-time.

## Constraints

- Do not mix imperative Three.js mutations with React state without clear boundaries.
