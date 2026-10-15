---
name: gltf-asset-pipeline
description: "Use this skill for glTF/GLB assets, compression, optimization, transforms, texture sizing, browser delivery."
---

# Gltf Asset Pipeline

## Decisions

- Record model provenance, units, axes, material extensions, texture sizes, and animation requirements.
- Validate glTF before and after compression; choose Meshopt/Draco/KTX2 based on actual loader support.

## Acceptance

Compare visual output, file size, load time, and fallback/device behavior.

## Constraints

- Do not ship oversized assets without compression and loading states.
