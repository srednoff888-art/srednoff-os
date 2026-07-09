# Srednoff OS Checkpoint 8 - NeuralDeep Importer

Date: 2026-07-09

## Scope

Checkpoint 8 adds a controlled metadata importer for NeuralDeep-style skills,
agents, MCP servers, and CLI tools.

## Implemented

- `integrations/neuraldeep/import-neuraldeep-registry.ps1`
- `integrations/neuraldeep/README.md`
- `scripts/test-srednoff-os-neuraldeep-importer.ps1`
- `evals/srednoff-os-neuraldeep-import-manifest.json`

## Safety Contract

The importer:

- reads a local manifest only;
- does not install external tools;
- does not enable candidates;
- does not allow `auto_install`;
- rejects unknown or non-allowlisted licenses by default;
- rejects non-HTTPS source URLs;
- rejects missing provenance;
- deduplicates against existing registry items and repeated manifest entries;
- writes trust scores for review only.

## External Research Notes

On 2026-07-09, public search confirmed that NeuralDeep exposes skills and MCP
catalog pages and that related projects reference `skillsbd` registry workflows.
Because catalog API stability is not guaranteed, this checkpoint keeps import
offline and manifest-driven.

Sources checked:

- https://neuraldeep.ru/skills
- https://neuraldeep.ru/mcp
- https://github.com/coddy-project/coddy-agent

## Validation

Expected release gate addition:

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-neuraldeep-importer.ps1"
```

