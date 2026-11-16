---
name: gltf-validation-release-gate
description: "Gate a glTF/GLB asset release on validator findings and renderer evidence."
---

# Gltf Validation Release Gate

## Decisions And Evidence

1. Use a pinned available Khronos validator and retain its machine-readable issue codes, asset statistics and artifact hash.
2. Triage errors versus justified warnings, then test framing, materials, animation and dimensions in the actual viewer.

## Boundary

Structural validity is not visual correctness or asset-license clearance; do not auto-upload confidential models.

## Source

[Current primary reference](https://github.com/KhronosGroup/glTF-Validator). Check the installed version and current contract before execution.
