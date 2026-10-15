---
name: 3d-product-configurator
description: "Implement or repair a product configurator where 3D options, authoritative pricing, inventory, and selected product state must agree."
---

# 3D Product Configurator
Define one product configuration state shared by the UI and scene. Treat model meshes as presentation, never as authoritative price or stock data.
## Decisions
- Map stable option IDs to materials/meshes; validate incompatible combinations against the product contract.
- Load critical content first; expose a usable image/text fallback while assets load or fail.
- Bound geometry, texture resolution, DPR, shadows, and concurrent downloads; dispose replaced GPU resources.
## Acceptance
Test each supported option, reset/share state, invalid combinations, and asset failure. Verify readable mobile framing, touch controls, keyboard-accessible options, nonblank screenshots, and actual product data integration.
