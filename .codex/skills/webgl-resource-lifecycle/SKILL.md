---
name: webgl-resource-lifecycle
description: "Diagnose GPU resource retention and context-loss recovery in Three.js/WebGL scenes."
---

# Webgl Resource Lifecycle

## Decisions And Evidence

1. Map ownership of geometries, materials, textures, image bitmaps, render targets, controls and animation callbacks.
2. Repeat mount/load/variant/unmount cycles and compare retained resources; exercise context-loss and error recovery.

## Boundary

Dispose shared resources only after their last owner releases them; do not claim memory safety from JS heap alone.

## Source

[Current primary reference](https://threejs.org/manual/pages/how-to-dispose-of-objects.html). Check the installed version and current contract before execution.
