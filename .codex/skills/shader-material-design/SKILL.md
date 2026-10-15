---
name: shader-material-design
description: "Develop or repair a specific real-time shader or material, with explicit renderer, color-space, precision, and device constraints."
---

# Shader Material Design
Identify the target renderer and shader language: WebGL GLSL, WebGPU WGSL, or Three.js TSL. Preserve the selected project stack.
## Decisions
- Specify inputs, uniforms, time units, coordinate space, linear/sRGB conversion, tone mapping, blending, and depth behavior.
- Control precision and texture sampling costs. Avoid unstable divisions, undefined derivatives, and frame-rate-dependent animation.
- Review provenance before adapting shader code; a public demo is not a reuse license.
## Acceptance
Compile on the actual target renderer, inspect console errors, compare screenshots, and capture frame-time on mobile and desktop. Verify reduced motion, canvas visibility, and fallback behavior.
