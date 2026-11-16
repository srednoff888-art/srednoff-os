---
name: 3d-performance-budget-gate
description: Use before shipping 3D web, WebGL, WebGPU, Three.js, Babylon.js, R3F, or shader-heavy UI.
---

# 3D Performance Budget Gate

## Task Decisions

1. Measure first usable frame, p95 frame time, draw calls, texture allocation and asset transfer on an agreed representative device.
2. Use a repeatable camera/interaction sequence; test the fallback separately and report measured budgets rather than universal polygon or FPS claims.

Use this skill for 3D Web work focused on set and validate frame time, draw calls, texture memory, shader cost, and mobile fallback.

## Guardrails

- Do not perform destructive, paid, production, publishing, account-changing, trading, legal, financial, or externally visible actions without explicit confirmation.
- Do not expose secrets, tokens, cookies, private keys, personal data, or confidential business data.
- Do not copy third-party code or assets without license/provenance review.
- If validation is impossible, state why and provide a concrete manual verification path.
