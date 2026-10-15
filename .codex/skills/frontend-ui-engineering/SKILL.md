---
name: frontend-ui-engineering
description: "Implement or repair interactive frontend UI in an existing web application, including async states, responsive layout, semantic controls, and keyboard behavior."
---

# Frontend UI Engineering
Inspect the route, shared components, styling system, and real data contract before changing UI. Reuse the project's tokens and primitives.
## Decisions
- Map loading, success, empty, validation, permission, and failure states to the actual request lifecycle. Ignore stale responses; preserve user input after retryable failure.
- Use native buttons/links/form semantics first. Define focus movement for overlays and validation; support keyboard dismissal and avoid inaccessible click-only containers.
- Constrain fixed-format boards, toolbars, and media with stable dimensions. Check long labels, localization, 200% zoom, mobile safe areas, and reduced motion.
- Keep server/client boundaries and hydration deterministic. Avoid shipping a new runtime for a small interaction.
## Acceptance
Exercise the primary workflow and at least one failure/retry path. Check mobile and desktop screenshots, keyboard navigation, console errors, and the existing build/type gates. Report mock-only data or unavailable backend paths explicitly.
