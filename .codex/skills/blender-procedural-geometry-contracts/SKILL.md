---
name: blender-procedural-geometry-contracts
description: "Build reproducible Blender Geometry Nodes assets with explicit parameters and export boundaries."
---

# Blender Procedural Geometry Contracts

## Decisions And Evidence

1. Record Blender version, units, exposed node inputs, deterministic seeds and attribute-domain assumptions.
2. Test parameter extremes, realization/export behavior and the editable source versus delivered geometry.

## Boundary

Do not apply destructive modifiers to the only source; isolate reviewed scripts from sensitive files.

## Source

[Current primary reference](https://docs.blender.org/manual/en/5.1/modeling/geometry_nodes/attributes_reference.html). Check the installed version and current contract before execution.
