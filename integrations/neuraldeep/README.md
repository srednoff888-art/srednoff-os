# NeuralDeep Controlled Importer

This integration imports NeuralDeep-style candidate metadata into the disabled
Srednoff OS registry. It is intentionally conservative:

- no network access by default;
- no package, MCP, CLI, or skill installation;
- no `enabled=true` output;
- no `auto_install=true` output;
- explicit license and provenance gates;
- duplicate detection before catalog writes;
- trust score metadata for review, not execution approval.

## Manifest

The importer accepts a local JSON manifest:

```json
{
  "schema": "srednoff-os.neuraldeep.import-manifest.v1",
  "source": "https://neuraldeep.ru/skills",
  "items": [
    {
      "id": "example-skill",
      "name": "Example Skill",
      "kind": "skill",
      "source_url": "https://neuraldeep.ru/skill/example-skill",
      "repo_url": "https://github.com/example/example-skill",
      "license": "MIT",
      "provenance": "NeuralDeep catalog entry with linked public repository.",
      "description": "Short human-reviewable summary."
    }
  ]
}
```

Supported `kind` values:

| Input kind | Target catalog |
|---|---|
| `skill` | `registry/neuraldeep/skills.json` |
| `agent` | `registry/neuraldeep/skills.json` |
| `mcp` | `registry/neuraldeep/mcp.json` |
| `mcp-server` | `registry/neuraldeep/mcp.json` |
| `cli` | `registry/neuraldeep/cli.json` |
| `cli-tool` | `registry/neuraldeep/cli.json` |

## Usage

```powershell
powershell -ExecutionPolicy Bypass -File ".\integrations\neuraldeep\import-neuraldeep-registry.ps1" `
  -InputPath ".\path\to\manifest.json" `
  -RegistryRoot ".\registry\neuraldeep" `
  -ReportPath ".\registry\neuraldeep\last-import-report.json"
```

Use `-DryRun` to generate a report without modifying registry files.

## Review Policy

Imported candidates stay disabled until a human reviews source provenance,
license, repository activity, tool permissions, prompt-injection risk, and
secret-exfiltration risk.

