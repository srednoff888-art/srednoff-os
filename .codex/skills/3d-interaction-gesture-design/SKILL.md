---
name: 3d-interaction-gesture-design
description: "Design or debug pointer, touch, keyboard, and camera interactions in an existing interactive 3D scene."
---

# 3D Interaction Gesture Design
Specify the gesture ownership of the scene and surrounding page before changing controls.
## Decisions
- Separate orbit, object drag, pinch, and page scroll. Use pointer capture and handle pointer cancellation.
- Bound camera distance, polar angles, and hit testing. Provide reset and keyboard equivalents for meaningful actions.
- Prefer touch gestures that preserve ordinary page navigation; do not capture every scroll or pinch.
## Acceptance
Test pointer down/move/up/cancel, multiple touches, viewport changes, focus, and reduced motion. Confirm gestures do not leave controls stuck or trap page scrolling.
