---
name: react-composition-contracts
description: "Refactor React component APIs with tangled boolean modes or shared state into explicit, testable composition contracts."
---

# React Composition Contracts

Inspect the installed React version and existing public props before changing a component API.
## Decisions
- Separate controlled state, actions, and presentation. Use a shared provider only when multiple real consumers need the same state.
- Replace incompatible boolean combinations with explicit variants or compound components when this simplifies actual callers.
- Keep accessible names, focus behavior, ref handling, and old callers working during migration. Check React-version support rather than blindly applying React 19 advice.
## Acceptance
Test representative existing callers, controlled/uncontrolled state, keyboard interactions, and variant combinations. Read the relevant official React contract when changing refs/context; do not load an entire performance-rule catalog for a local API fix.
