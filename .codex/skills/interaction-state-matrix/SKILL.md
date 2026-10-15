---
name: interaction-state-matrix
description: "Use this skill for hover, focus, active, loading, empty, error, success, permission and offline states."
---

# Interaction State Matrix

## Decisions

- Enumerate user actions against loading, success, error, empty, disabled, and permission states.
- Define focus, feedback, cancellation, and retry for meaningful transitions.

## Acceptance

Exercise the matrix in the rendered interface and identify unsupported combinations.

## Constraints

- Do not leave core flows with undefined error or empty states.
