---
name: accessibility-wcag-aa
description: "Find and fix accessibility failures in a web interface using WCAG 2.2 AA criteria, keyboard checks, and assistive-technology evidence."
---

# Accessibility WCAG AA
Use automated scans to find candidates, then confirm user impact manually.
## Decisions
- Check semantic names/roles, focus order and visibility, keyboard operation, error identification, contrast, zoom/reflow, and target size.
- Give overlays a correct focus lifecycle and return focus to the trigger. Prefer native controls over custom ARIA.
- Test form labels, help/error associations, live regions, motion preferences, and alternatives for canvas/media.
## Acceptance
Verify the primary workflow with keyboard and a screen reader where available. Report exact failures and criteria. A clean automated scan does not prove WCAG conformance.
