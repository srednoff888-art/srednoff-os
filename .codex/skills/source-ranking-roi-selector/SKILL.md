---
name: source-ranking-roi-selector
description: "Compare UI/component/3D sources for task fit, provenance, license, runtime cost, accessibility, and practical validation."
---

# Source Ranking ROI Selector

Use this skill to choose external sources without spending context on every option.

## Workflow

1. Run the source ranker:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\srednoff-os-source-ranker.ps1" -ProjectPath "<project-path>" -Brief "<task>" -Json
```

2. Prefer the highest-ranked source only when it matches the project stack and validation budget.
3. For medium/high-risk sources, verify license, provenance, dependency weight, accessibility, performance, and copied-code risk before use.
4. For UI sources, prefer local design system and shadcn-compatible copy-adapt workflows before heavy animated libraries. Consider Astryx only for React 19 projects that justify a cohesive pre-1.0 design system plus StyleX peer dependency.
5. For 3D sources, prefer `model-viewer` for simple product display, R3F/Three.js for React custom scenes, and glTF Transform for optimization.
6. In TURBO, compare more sources, but keep the same safety and license gates.

## Checklist

- Source fits stack, visual goal, and maintenance budget.
- License/provenance is known before copying code or assets.
- Dependency and asset-size cost is justified.
- Accessibility, responsive behavior, visual QA, and performance gates are defined.
- Only selected source details are loaded into context.

## Guardrails

- Do not copy third-party code or assets without license/provenance review.
- Do not use marketplace assets with unclear licenses in production.
- Do not choose a visually impressive source if it harms maintainability, accessibility, or performance without a clear payoff.
- Do not adopt pre-1.0 design systems or their lab/canary packages without an explicit upgrade, dependency, accessibility, and rollback plan.
