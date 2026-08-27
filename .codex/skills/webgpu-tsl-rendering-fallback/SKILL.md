---
name: webgpu-tsl-rendering-fallback
description: Use when a Three.js web experience needs WebGPU rendering, TSL shaders, node-based post-processing, or a WebGL2 fallback. Apply it to renderer selection, shader migration, compatibility validation, and performance budgeting; do not use it for a simple static model viewer.
---

# WebGPU TSL Rendering Fallback

WebGPU is an enhancement path, not a universal baseline. Preserve equivalent
critical content and interaction on WebGL2 or an appropriate non-3D fallback.

## Workflow

1. Establish target browsers/devices, visual acceptance criteria, frame-time,
   memory, download, shader complexity, and fallback budgets.
2. Use `WebGPURenderer` only with an explicit WebGL2 fallback. Prefer TSL for
   new portable shader and post-processing work rather than adding legacy-only
   material hooks.
3. Keep renderer initialization async, feature-detect capabilities, dispose GPU
   resources, and degrade motion/effects before degrading core content.
4. Validate both renderer paths with screenshots, nonblank canvas checks,
   interaction tests, GPU/CPU profiling, and mobile devices.

## Guardrails

- Do not claim visual parity until both WebGPU and fallback runs were tested.
- Avoid WebGPU-only assets, controls, or business-critical information.
- Confirm licenses and dimensions for HDRIs, textures, models, and shader code.
