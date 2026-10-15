---
name: blender-web-asset-authoring
description: "Create or repair a Blender model intended for glTF/GLB web delivery, preserving source dimensions, materials, geometry, provenance, and runtime budgets."
---

# Blender Web Asset Authoring

Start from approved source measurements/images and an existing .blend file when available. Define the intended web renderer, interactions, and asset budget.
## Decisions
- Keep units, axis orientation, scale, origins, topology, normals, UVs, and material names deliberate. Use non-destructive construction where it supports revision.
- Test exporter support for materials, modifiers, lights, and animation. Blender shader graphs may need baking or a glTF-compatible material.
- Export a versioned GLB, validate its structure, and compare it in the target web viewer against the source model.
- Blender MCP can execute generated Python. Use an isolated non-sensitive test environment and reviewed bounded operations; official status alone does not make code execution safe.
## Acceptance
Deliver the editable source, GLB, texture/license inventory, dimensions, polygon/texture/byte counts, and renderer screenshots. Verify mobile load, framing, materials, interaction, and fallback; disclose unsupported visual features.
