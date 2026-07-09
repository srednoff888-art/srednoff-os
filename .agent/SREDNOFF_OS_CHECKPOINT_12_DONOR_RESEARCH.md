# Srednoff OS Checkpoint 12 - Donor Repository Research

Date: 2026-07-09

## Goal

Review the three user-supplied Fable/system-prompt repositories and migrate only clean-room, vendor-neutral patterns into Srednoff OS.

## GitHub Research

Search intent:

- Review public donor repositories that claim to contain or analyze Fable 5/system prompts.
- Extract only durable engineering patterns: provenance, compact instruction layering, tool-contract review, validation gates, and source taxonomy.
- Reject leaked/proprietary prompt text, model identity claims, hidden policy reconstruction, and unlicensed content.

Repos checked:

| Repo | Current signal at review | Useful pattern | Risk | Decision |
|---|---:|---|---|---|
| `cyrus-tt/fable5-system-prompt` | 30 stars, 18 forks, pushed 2026-06-15, no license detected | Full/lite split as a distillation pattern | High: no license and claimed leak | Monitor only |
| `saynchowdhury/claude-fable-5-system-prompt` | 122 stars, 55 forks, pushed 2026-07-04, GitHub licenseInfo `Other` | Separate analysis, issue templates, verification script, tool-definition taxonomy | High: prompt content itself is not safe to copy | Adapt structure only |
| `asgeirtj/system_prompts_leaks` | 54637 stars, 8894 forks, pushed 2026-07-08, CC0 repository license | Broad source taxonomy, bundled-skill directory shape, progressive disclosure references | Medium-high: archive may contain vendor-owned prompt text | Taxonomy only |

## Adopted

- Added `.codex/srednoff-os/donor-research.json` as a machine-readable donor decision manifest.
- Added `scripts/validate-donor-research.ps1` to enforce provenance, license/risk fields, quarantine decisions, and prompt-text rejection.
- Connected donor research validation to `srednoff-os-doctor.ps1` and GitHub Actions.
- Updated public release evidence so donor research is a checked gate, not only a prose note.

## Rejected

- No vendor prompt text was copied.
- No model identity, roadmap, hidden policy, or product-tier claims were adopted.
- No third-party scripts, assets, or prompt blocks were imported.

## Implementation Impact

The existing `external-prompt-pattern-miner` skill remains the runtime workflow. Checkpoint 12 adds durable release metadata and validation so future donor/source mining cannot silently bypass the provenance gate.
