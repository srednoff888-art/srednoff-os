---
name: threejs-mcp-apps-preview
description: Use when building an MCP Apps interactive UI that previews or controls a Three.js scene, shader, product model, or visual prototype. Apply sandboxing, CSP, fallback, performance, and source-provenance controls before exposing generated 3D content to users.
---

# Three.js MCP Apps Preview

Build an interactive preview as a bounded tool UI, not as a general remote-code
execution environment. Start with a compact scene contract and accessible text
fallback.

## Workflow

1. Define the scene inputs, allowed assets, interaction model, rendering budget,
   target host, and a non-canvas fallback before implementation.
2. Use MCP Apps `ui://` resources with restrictive CSP and typed tool inputs.
   Keep scene code, assets, and URLs allowlisted rather than evaluating arbitrary
   model-generated JavaScript.
3. Pause animation when hidden, cap DPR/texture/model budgets, release GPU
   resources, and provide reduced-motion behavior.
4. Validate screenshots, nonblank canvas, keyboard controls, mobile fallback,
   CSP behavior, and tool-result provenance before release.

## Guardrails

- Treat the official Three.js MCP Apps example as a reference implementation,
  not a production-ready code copy.
- Do not fetch arbitrary model URLs or execute user/model supplied scene code.
- Keep MCP App UI actions separate from account, asset-publishing, or deployment
  permissions.
