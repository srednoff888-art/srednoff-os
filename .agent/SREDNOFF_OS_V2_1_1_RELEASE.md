# Srednoff OS v2.1.1 Release

Released: 2026-06-30

## Purpose

v2.1.1 upgrades Srednoff OS for high-return project work in UI/UX, web design, 3D web design, mobile/apps, SEO/PPC/growth, and programming across languages.

## Added

- `TURBO` mode: explicit command-only maximum-quality workflow with `budget=turbo`, up to 48 selected capabilities, and unchanged safety gates.
- Mode router: classifies normal/deep/turbo work before capability selection.
- Domain router: detects UI/UX, web design, 3D web, mobile/apps, SEO/PPC/growth, programming, and general work.
- Design source registry: 21st.dev via Magic, shadcn registry, Magic UI, Aceternity UI, Origin UI, React Bits, Figma, Canva, Three.js, React Three Fiber, Babylon.js, model-viewer.
- 48 compact skills/agent profiles for design brief intake, component source routing, copy-adapt-review, 3D validation, mobile release gates, growth message match, programming provenance, and TURBO validation.
- v2.1.1 eval suite for mode routing, domain routing, MCP inventory, hook safety, and TURBO behavior.

## Changed

- `quality-cost-skill-kernel` now supports `turbo` budget in the PowerShell wrapper and Python selector.
- `AGENTS.md` startup notification and diagnostics now reference v2.1.1.
- UI/UX and 3D web work now explicitly routes through design brief, source selection, provenance/license review, and visual validation.
- External code/component reuse is treated as copy-adapt-upgrade, not blind copying.

## Safety

TURBO does not bypass destructive-change, paid-action, production, secret, license, or irreversible-migration confirmations.

## Validation

Run:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\test-srednoff-os-v211.ps1" -ProjectPath "<project-path>"
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\srednoff-os-doctor.ps1" -ProjectPath "<project-path>" -RunEvals -FixSafe
```
