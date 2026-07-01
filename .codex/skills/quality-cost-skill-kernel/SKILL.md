---
name: quality-cost-skill-kernel
description: Token-aware routing kernel for selecting the smallest useful set of Codex skills, agent profiles, scripts, and review passes. Use at the start of new or existing projects, before substantial implementation, audits, research, UI/UX, SEO, PPC, crypto, app, automation, or multi-domain work, when the goal is high quality without unnecessary token spend.
---

# Quality Cost Skill Kernel

Use this skill to choose capabilities by value per token instead of loading every possible instruction. The selector uses the `legacy-plus` principle: keep the 3000-record catalog, Group 1/2/3 quotas, non-overlap, domain caps, and compact mapped `SKILL.md` reads, then add v2.1.2 ROI/source/design signals on top.

## Workflow

1. Restate the outcome, risk level, budget mode, and definition of done.
2. Run the selector instead of reading the full 3000-record catalog:

```bash
python scripts/select_core_capabilities.py --project <project-path> --brief "<task>" --budget balanced --max 24
```

Use `--budget lean` for cheap discovery and small fixes, `balanced` for normal project work, `deep` for high-risk architecture, launch, security, migration, SEO, PPC, crypto, or production review work, and `turbo` only when the user explicitly writes `TURBO`.

3. Read only the selected capability records, mapped existing `SKILL.md` files, and directly relevant references. Do not load the full catalog into model context.
4. Prefer Group 1 capabilities first, then add Group 2 only when it changes the result. Use Group 3 when the expected output justifies deeper research, multi-agent review, simulation, or heavyweight validation.
5. Use the displayed estimated ROI and context cost as tie-breakers when two capabilities solve the same failure mode.
6. After finishing, note any missing capability, stale routing term, or repeated manual workflow so the catalog can be improved.

## Token Groups

- Group 1: saves tokens or has near-zero context cost. Examples: local project scanners, dependency inventories, static checks, index generation, deterministic scripts.
- Group 2: costs some context but pays for itself in better implementation, design, validation, or focused research.
- Group 3: expensive but justified when the result is concrete: deep research, multi-agent review, red-team, migration simulation, competitive analysis, launch readiness. In `turbo`, use more Group 3 records but keep safety, license, paid-action, production, and destructive-change confirmations.

## Resources

- `references/core-3000-capabilities.json`: canonical catalog. Do not load the whole file into context unless explicitly auditing the catalog.
- `scripts/select_core_capabilities.py`: project/task-aware selector.
- `scripts/validate_core_catalog.py`: structural validation for count, uniqueness, groups, and routing fields.
- `scripts/build_core_catalog.py`: deterministic generator for the 3000-record catalog.
