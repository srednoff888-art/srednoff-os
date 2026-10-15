---
name: swiftui-state-data-flow
description: "Use this skill for SwiftUI state management, bindings, models, observation, persistence, async data."
---

# Swiftui State Data Flow

## Decisions

- Map source-of-truth state, bindings, observation, async tasks, and navigation lifetime.
- Handle actor isolation, cancellation, view identity, and persistence deliberately.

## Acceptance

Test rapid navigation, concurrent loading, scene recreation, and stale-result behavior.

## Constraints

- Do not create state duplication that causes stale UI.
