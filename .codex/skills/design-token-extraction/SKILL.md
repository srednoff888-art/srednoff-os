---
name: design-token-extraction
description: "Use this skill for extracting colors, typography, spacing, radii, shadows, tokens from UI references."
---

# Design Token Extraction

## Decisions

- Identify approved source variables and distinguish semantic tokens from raw visual values.
- Preserve alias relationships, theme overrides, units, and component-specific exceptions.

## Acceptance

Validate generated tokens against representative components and flag unresolved design/code conflicts.

## Constraints

- Do not create tokens that contradict the existing product style.
