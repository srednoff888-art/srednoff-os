---
name: component-storybook-workshop
description: "Use this skill for component libraries, Storybook stories, variants, controls, visual states, documentation."
---

# Component Storybook Workshop

## Decisions

- Model component variants and real loading/error/focus states as stories using the current design system.
- Keep mocks explicit and add interaction tests for behavior that props alone cannot verify.

## Acceptance

Run the Storybook build and review keyboard, viewport, and visual states.

## Constraints

- Do not add stories that cannot be rendered or maintained with the app code.
