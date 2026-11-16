---
name: blender-topology-uv-quality
description: "Review topology, normals and UVs before texturing or web export of a Blender model."
---

# Blender Topology Uv Quality

## Decisions And Evidence

1. Inspect scale, intended silhouette, seams, texel density, overlaps and deformation requirements before cleanup.
2. Compare checker/stretch views and lighting at delivery scale; preserve intentional mirrored UVs and source geometry.

## Boundary

Do not blindly merge vertices, recalculate all normals or overwrite the only UV map.

## Source

[Current primary reference](https://docs.blender.org/manual/en/5.1/modeling/meshes/editing/uv.html). Check the installed version and current contract before execution.
