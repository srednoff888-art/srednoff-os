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
