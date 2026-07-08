# Srednoff OS vNext Checkpoints

Date started: 2026-07-09

Purpose: implement the vNext roadmap in small auditable checkpoints. Every checkpoint must be applied to Srednoff OS, validated, committed, and pushed before moving to the next one.

## Execution Rule

1. Work on one checkpoint at a time.
2. Keep public core and personal profile state separate.
3. Do not copy third-party code without license and provenance review.
4. Do not install NeuralDeep skills, MCP servers, or CLI tools automatically.
5. Add or update evals for behavior-changing work.
6. Run the relevant validation gate.
7. Update this file, `QUALITY.md`, and `CHANGELOG.md` when the checkpoint changes public release evidence.
8. Commit and push to `main`.

## Checkpoint Table

| ID | Checkpoint | Scope | Required output | Status |
|---:|---|---|---|---|
| 0 | Preflight audit and baseline | Inspect repo, docs, scripts, evals, CI, NeuralDeep availability, donor repo availability, current risks | `.agent/SREDNOFF_OS_CHECKPOINT_0_PREFLIGHT.md` | Done |
| 1 | Public core vs personal profiles | Remove personal hardcoded paths from public core and define public/private boundaries | Public-safe path handling and profile boundary notes | Done |
| 2 | AGENTS.md entrypoint | Convert AGENTS.md from full rule dump into a compact entrypoint with linked docs | Smaller startup surface and moved reference docs | Next |
| 3 | Profile system | Add public-default, ivan, agency, and ru-market profile scaffolding | `profiles/` structure and selection rules | Pending |
| 4 | Quality modes | Add fast, standard, production, and critical modes | Mode metadata and router/eval coverage | Pending |
| 5 | Security hook upgrade | Strengthen destructive command, secret leak, ask/deny, and audit-log handling | Hook behavior plus security fixtures | Pending |
| 6 | RU risk policies | Add NeuralDeep, marketplace, payments, messaging, and RU data policies | `policies/*.yml` plus policy evals | Pending |
| 7 | NeuralDeep registry skeleton | Add skills, MCP, CLI, index, trust report, and import log structure | `registry/neuraldeep/` safe disabled registry | Pending |
| 8 | NeuralDeep importer | Add importer, mapper, audit, README; support API when available and HTML fallback when API is absent | `integrations/neuraldeep/` tooling and evals | Pending |
| 9 | RU bundles | Add ru-seo, ru-marketplaces, ru-enterprise, ru-1c, ru-llm, ru-content, ru-payments, ru-messaging, ru-devops bundles | `bundles/ru-*` metadata | Pending |
| 10 | RU agents | Add RU specialist agent profiles for SEO, marketplaces, 1C, enterprise, LLM, content, payments, messaging | `agents/ru-*.md` | Pending |
| 11 | RU CLI compatibility scripts | Add safe search, import, audit, install wrappers that recommend commands without silent execution | `scripts/srednoff-os-ru-*.ps1` | Pending |
| 12 | Donor repository research | Review listed Codex/agent donor repos and adapt only clean-room patterns | Research notes and selected changes | Pending |
| 13 | Documentation upgrade | Add architecture, security, workflows, profiles, hooks, NeuralDeep, RU integrations, RU risk model docs | `docs/*.md` | Pending |
| 14 | Full validation and public release note | Run release gate, update README, QUALITY, CHANGELOG, and final report | Green local checks and GitHub Actions | Pending |

## Current Position

Checkpoint 1 is complete. The next implementation checkpoint is checkpoint 2: AGENTS.md entrypoint.
