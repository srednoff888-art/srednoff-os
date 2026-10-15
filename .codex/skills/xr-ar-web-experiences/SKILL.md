---
name: xr-ar-web-experiences
description: "Use this skill for WebXR, AR previews, model-viewer, mobile sensors, permissions, fallback UX."
---

# XR AR Web Experiences

## Decisions

- Define supported hardware/browser capabilities, permissions, tracking space, and non-XR fallback.
- Model session start/end, lost tracking, scale, interactions, and user safety without assuming headset support.

## Acceptance

Test supported devices and record permission/refusal, tracking, and fallback gaps.

## Constraints

- Do not require XR hardware when a non-XR fallback is needed.
