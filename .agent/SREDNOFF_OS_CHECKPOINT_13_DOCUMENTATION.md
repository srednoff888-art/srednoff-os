# Srednoff OS Checkpoint 13 - Documentation Upgrade

Date: 2026-07-09

## Goal

Move public Srednoff OS documentation from README-heavy release notes into a structured `docs/` portal with architecture, security, workflows, profiles, RU/NeuralDeep, risk, and validation references.

## Added

| File | Purpose |
|---|---|
| `docs/README.md` | Documentation index and navigation |
| `docs/architecture.md` | System map, ownership boundaries, startup flow, selector flow, release evidence path |
| `docs/security.md` | Hook posture, decisions, redacted audit trail, provenance gates, private boundary |
| `docs/workflows.md` | Project workflow, maintenance workflow, checkpoint flow, TURBO, source intake |
| `docs/profiles.md` | Profile index, public core boundary, old-session sync |
| `docs/ru-and-neuraldeep.md` | RU policies, bundles, agents, CLI wrappers, NeuralDeep registry/importer |
| `docs/risk-model.md` | Risk classes, source risk, blocked actions, residual risks |
| `docs/validation.md` | Local gate, CI gate, evidence files |
| `scripts/validate-docs.ps1` | Deterministic docs presence/index validator |

## Boundaries

- No runtime behavior changed.
- No external code or prompt text was copied.
- The docs describe current repository behavior and validation evidence only.

