# Selector Research Notes

Date: 2026-07-01.

Goal: improve Srednoff OS selector behavior using internal Srednoff OS skills plus current GitHub research, without copying third-party code.

## Repositories Checked

| Repo | Relevance | Useful pattern | Applied in Srednoff OS |
|---|---|---|---|
| `langchain-ai/langchain` | Provider-side tool search and deferred tool loading | Validate requested tool names and keep provider/search behavior explicit | Added visible direct skill matches and local index fallback diagnostics |
| `openai/evals` | Eval registry and benchmark organization | Registry paths, aliases, closest-match diagnostics, fixture-driven evaluation | Added stronger selector fixture semantics with `expectedAll` |
| `microsoft/autogen` | Agent framework migration and selector/stateflow docs | Versioned architecture changes and explicit migration notes | Kept v2.1.1 and v2.1.2 eval suites separate |
| `crewAIInc/crewAI` | Multi-agent orchestration framework | Clear role/task separation | Preserved skill/agent distinction instead of merging everything into one selector rule |
| `modelcontextprotocol/servers` | Reference implementations and safety warnings | Clear reference-vs-production positioning | Added honest `QUALITY.md` and non-goal statements |
| `openai/codex` | Coding agent UX baseline | Quickstart-first developer packaging | Kept public repo onboarding short and validation commands visible |

## Decisions

- Adopt: local registry/index fallback, explicit selector diagnostics, stronger eval fixtures.
- Adapt: multi-tool visibility from provider-side tool search into selector `ids` output.
- Avoid: copying framework code or adding heavyweight runtime dependencies.
- Build ourselves: PowerShell/Python-compatible local clone behavior and smoke validation.

## Follow-Up Candidates

- Add `--format json` for machine-readable selector output.
- Add per-record `matched_terms` to make scoring easier to debug.
- Track selector precision/recall over a larger fixture set.
- Add a CI workflow once repository automation policy is defined.

---

Date: 2026-07-02.

Goal: add 1500 high-value skill/agent capability records and improve selector quality/speed without loading the expanded catalog into model context.

## GitHub Research Summary

| Repo | Why relevant | What to reuse | Risks |
|---|---|---|---|
| `langchain-ai/langchain` | Large active agent/tooling ecosystem with explicit tool routing concerns; MIT; ~140k stars; updated 2026-07-01 | Registry-first routing, provider/tool search concepts, avoid eager loading | Too broad to copy; patterns only |
| `openai/evals` | Eval registry and benchmark organization; ~18k stars; updated 2026-07-01 | Fixture-driven selector regression coverage | License is not MIT; no code copying |
| `microsoft/autogen` | Agentic framework with versioned architecture and multi-agent patterns; ~59k stars; updated 2026-07-01 | Keep agent roles bounded and versioned | CC-BY-4.0 licensing means patterns only |
| `crewAIInc/crewAI` | Role/task orchestration; MIT; ~54k stars; updated 2026-07-01 | Preserve skill vs agent separation and task-bound selection | Avoid importing orchestration complexity |
| `microsoft/semantic-kernel` | Plugin/function registry model; MIT; ~28k stars; updated 2026-07-01 | Stable capability metadata and compact function selection | Multi-language framework is heavier than needed |
| `confident-ai/deepeval` | LLM evaluation framework; Apache-2.0; ~16k stars; updated 2026-07-01 | Add benchmark/eval capability templates and selector fixtures | Do not add runtime dependency for local selector |

Decision:
- Adopt: deterministic catalog expansion, stronger catalog invariants, portable local skill index, extra selector fixture for speed/ROI capabilities.
- Avoid: adding a third-party agent framework or eval dependency to the selector path.
- Build ourselves: 4500-record generator, 4500 validator, local index wrapper optimization, and compatibility-preserving legacy catalog filename.

## Applied

- Added 25 curated capability templates across all 60 domains: 10 Group 1, 10 Group 2, 5 Group 3.
- New catalog size: 4500 records; Group 1/2/3 distribution: 1800/1800/900; skill/agent records: 3300/1200.
- Added validator checks for per-domain record counts, per-domain group counts, and total unique capability slugs.
- Added selector fixture `selector_catalog_speed_roi`.
- Added portable `.codex/skill-index.json` and wrapper preference for the local index.
- Optimized selector scoring by computing file-signal text once and precomputing skill tokens for mapped skill selection.
