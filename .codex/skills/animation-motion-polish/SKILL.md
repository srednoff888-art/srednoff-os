---
name: animation-motion-polish
description: "Implement or refine interface animation with a clear state transition, interruption behavior, and reduced-motion fallback."
---

# Animation Motion Polish
Give each transition a functional purpose and define its start/end states.
## Decisions
- Prefer transform/opacity for simple transitions; inspect layout/repaint costs for other properties.
- Handle interrupted transitions, repeated clicks, unmounts, and back navigation without stale state.
- Keep timings consistent with the existing motion system and support prefers-reduced-motion.
## Acceptance
Test rapid repeated interaction, loading/error transitions, keyboard use, and reduced motion. Profile visible jank and ensure animation does not delay access to content.
