# NeuralDeep Registry Skeleton

This registry is a safe, disabled-by-default holding area for NeuralDeep skills, MCP servers, and CLI tools.

It is not an installer. It must not enable, execute, or copy external tools automatically.

## Rules

- `enabled` must remain `false` until a human explicitly approves a specific item.
- `auto_install` must remain `false`.
- Every imported item needs provenance, license, source URL, risk level, and policy gates.
- MCP servers and CLI tools require explicit confirmation before installation or execution.
- Prompt-like or instruction-like text must be pattern-extracted, not copied verbatim when license is unclear.

## Files

| File | Purpose |
|---|---|
| `index.json` | Registry entrypoint and source map |
| `skills.json` | Skill candidates from NeuralDeep |
| `mcp.json` | MCP server candidates from NeuralDeep |
| `cli.json` | CLI tool candidates from NeuralDeep |
| `trust-report.json` | Trust rules and current risk assessment |
| `import-log.json` | Append-only import event structure |
