---
name: texture-compression-device-matrix
description: "Validate KTX2/Basis and glTF texture compression on target rendering devices."
---

# Texture Compression Device Matrix

## Decisions And Evidence

1. Map texture purpose, color space, alpha and mip requirements to supported decoder/transcoder paths.
2. Measure transfer, decode time and actual GPU allocation; compare material output on the real backend/device matrix.

## Boundary

Keep an approved fallback where needed; compressed bytes are not decoded memory and normal maps are not color textures.

## Source

[Current primary reference](https://threejs.org/docs/pages/GLTFLoader.html). Check the installed version and current contract before execution.
