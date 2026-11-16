---
name: 3d-visual-screenshot-validator
description: Use before finishing Three.js, R3F, WebGL, WebGPU, model-viewer, or 3D web UI work.
---

# 3D Visual Screenshot Validator

## Task Decisions

1. Capture the intended camera view after model/texture readiness, then move the camera or change a variant and capture again.
2. Check actual canvas pixel variance, model bounds, clipping, missing textures and UI overlap; a successful HTTP load is not rendering evidence.

Use this skill for 3D Web work focused on validate canvas renders, screenshots, framing, nonblank pixels, mobile viewports, and asset loading.

## Guardrails

- Do not perform destructive, paid, production, publishing, account-changing, trading, legal, financial, or externally visible actions without explicit confirmation.
- Do not expose secrets, tokens, cookies, private keys, personal data, or confidential business data.
- Do not copy third-party code or assets without license/provenance review.
- If validation is impossible, state why and provide a concrete manual verification path.
