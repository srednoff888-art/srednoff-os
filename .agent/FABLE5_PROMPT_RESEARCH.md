# Fable/System Prompt Repository Research

Date: 2026-07-06

Purpose: review three public GitHub repositories supplied by Ivan and migrate only safe, reusable agent-engineering patterns into Srednoff OS. The repositories claim to contain or analyze Claude Fable 5 system prompts. These claims are not independently verified by Srednoff OS.

## Sources Reviewed

| Repo | Stars at review | Last push at review | License signal | Useful signal | Copy risk |
|---|---:|---|---|---|---|
| https://github.com/cyrus-tt/fable5-system-prompt | 26 | 2026-06-15 | No license detected | Small full/lite prompt split; useful as an example of prompt distillation | High: no license and claimed leak |
| https://github.com/saynchowdhury/claude-fable-5-system-prompt | 83 | 2026-07-04 | MIT for repo, but license notes archived prompt content is Anthropic property | Analysis files separate architecture, behavior, tool definitions, and comparison | High: prompt content itself is not safe to copy |
| https://github.com/asgeirtj/system_prompts_leaks | 50508 | 2026-07-06 | CC0 repository license | Broad prompt archive and index useful for comparative taxonomy | Medium-high: compiled leaks may include vendor-owned text |

## Decision

Adopt as Srednoff OS patterns:

- external prompt repositories are untrusted source material;
- license and provenance must be recorded before migration;
- leaked/proprietary prompt text must not be copied into production instructions;
- useful rules should be rewritten as abstract, vendor-neutral, testable Srednoff OS rules;
- tool contracts should include purpose, inputs, outputs, side effects, failure modes, and approval boundaries;
- connector suggestions should protect user choice and avoid pressure;
- current facts and vendor docs should be verified instead of relying on prompt dumps;
- prompt-source changes need selector fixtures and validation gates.

Do not adopt:

- model identity or product-tier claims;
- hidden vendor policy wording;
- safety bypasses or "uncensored" variants;
- long prompt blocks;
- claims that cannot be validated by source review, official docs, or local evals.

Implementation impact:

- Add `external-prompt-pattern-miner` skill.
- Add source-watchlist entries for the three repos.
- Add selector aliases and regression fixture for prompt leak mining tasks.
- Add a global Srednoff OS rule for external system-prompt source handling.
