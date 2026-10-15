---
name: threejs-scene-architecture
description: "Use this skill for Three.js scene graph, renderer, camera, lighting, controls, loading lifecycle."
---

# Threejs Scene Architecture

## Decisions

- Define scene ownership, assets, renderer/camera lifecycle, interaction, and fallback boundaries.
- Keep loading/disposal explicit; isolate business state from render state and budget draw calls/textures.

## Acceptance

Test scene creation, resize, teardown, asset failure, and mobile framing.

## Constraints

- Do not create a heavy 3D scene without performance and fallback considerations.
