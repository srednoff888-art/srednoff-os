---
name: webgl-webgpu-performance
description: "Use this skill for GPU performance, draw calls, materials, instancing, shaders, profiling WebGL/WebGPU."
---

# Webgl Webgpu Performance

## Decisions

- Measure frame-time, CPU/GPU work, draw calls, texture memory, and downloads on target devices.
- Optimize the dominant bottleneck; adapt DPR/effects and pause hidden animation before removing content.

## Acceptance

Compare repeated traces and verify WebGL/WebGPU fallbacks and visual quality.

## Constraints

- Do not optimize blindly without measuring frame time and memory pressure.
