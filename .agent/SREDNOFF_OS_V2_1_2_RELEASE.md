# Srednoff OS v2.1.2 Release

Released: 2026-06-30

## Purpose

v2.1.2 improves ROI per token for selector-driven work and adds compact source-ranking/design-brief preflight for UI/UX, web design, 3D web design, and 3D asset workflows.

## Added

- `srednoff-os-source-ranker.ps1`: ranks UI kits, design connectors, component registries, 3D libraries, 3D assets, textures, models, and optimizers by fit, risk, dependency cost, gates, and ROI.
- `srednoff-os-design-brief.ps1`: generates only high-value UI/UX and 3D questions, with safe assumptions when questions are non-blocking.
- `source-ranking-roi-selector` skill.
- `design-brief-autogenerator` skill.
- v2.1.2 eval suite for selector mapping, source ranking, design brief, domain router helper scripts, and registry sources.

## Changed

- Selector now uses `legacy-plus`: old catalog/quota/non-overlap/domain-cap behavior remains, while brief-weighted scoring, intent-domain boosts, estimated context cost, and estimated ROI are added as tie-breakers and precision signals.
- `design-source-registry.json` now includes extra 3D sources: Babylon.js, glTF Transform, Khronos glTF Sample Assets, Poly Haven, ambientCG, and Sketchfab.
- `AGENTS.md` now requires compact design brief and source ranking before UI/3D source decisions.

## Safety

External UI/3D code and assets require source, license, provenance, dependency, accessibility, performance, visual QA, and asset-budget review before production use.

## Validation

Run:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\test-srednoff-os-v212.ps1" -ProjectPath "<project-path>"
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\srednoff-os-doctor.ps1" -ProjectPath "<project-path>" -RunEvals -FixSafe
```
