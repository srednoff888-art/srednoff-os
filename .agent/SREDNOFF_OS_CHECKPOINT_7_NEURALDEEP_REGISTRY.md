# Checkpoint 7 NeuralDeep Registry Skeleton

Date: 2026-07-09

## Scope

Create a safe disabled-by-default registry skeleton for NeuralDeep skills, MCP servers, and CLI tools.

## External Source Check

| Source | Observed status | Decision |
|---|---|---|
| `https://neuraldeep.ru/skills` | Public catalog page for skills/MCP/CLI around Russian services | Use as source metadata only |
| `https://neuraldeep.ru/mcp` | Public MCP catalog page | Treat MCP entries as high risk until reviewed |
| `https://neuraldeep.ru/cli` | Public CLI catalog page | Treat CLI entries as high risk until reviewed |
| `https://neuraldeep.ru/skill/find-skills` | Example skill page | Candidate only, disabled |
| `https://neuraldeep.ru/skill/1c-lsp-mcp-skill` | Example skill/MCP page | Candidate only, disabled |
| `https://neuraldeep.ru/skill/mcp-max-messenger` | Example messenger MCP page | Candidate only, disabled and policy-gated |

## Safety Decisions

- No external command is installed or executed.
- No MCP server is enabled.
- No prompt-like or license-unclear instruction text is copied.
- Every candidate has `enabled=false` and `auto_install=false`.
- Trust report says `trusted_for_execution=false`.
- Import log records only skeleton creation.

## Validation

`scripts/test-srednoff-os-neuraldeep-registry.ps1` validates JSON, required files, disabled state, no auto install, item provenance, license field, policy gates, and no secret-like content.
