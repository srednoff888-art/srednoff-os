# RU And NeuralDeep

This document covers Russian-market metadata and NeuralDeep/source-import handling.

## RU Policies

| Policy | Gate |
|---|---|
| `ru-data` | personal data, localization, consent, storage, export, regulated processing |
| `ru-payments` | invoices, receipts, PSPs, fiscalization, refunds, customer financial data |
| `ru-messaging` | messenger/customer data, payment document transfer, externally visible communication |
| `ru-marketplaces` | marketplace terms, claims, reviews, ads, ERIR-sensitive work |
| `neuraldeep` | external skills, agents, MCP servers, CLI tools, and prompt-like imports |

The default posture is human review before regulated or externally visible action.

## RU Bundles

Bundles are disabled metadata presets. They help the selector choose relevant local context without loading broad instructions.

| Bundle | Purpose |
|---|---|
| `ru-seo` | Russian SERP, local SEO, Yandex/Google checks |
| `ru-marketplaces` | Marketplace listing and operations review |
| `ru-enterprise` | Enterprise constraints and approval flows |
| `ru-1c` | 1C-related integration and data workflows |
| `ru-llm` | LLM/RAG/agent/MCP workflows with prompt security |
| `ru-content` | Russian-language content quality and compliance posture |
| `ru-payments` | Payment and document workflow review |
| `ru-messaging` | Messenger and communication workflow review |
| `ru-devops` | Deployment, observability, and environment workflow hints |

## RU Agent Profiles

RU agent profiles are compact role lenses. They are selector-only and disabled by default. They do not spawn autonomous agents or execute tools by themselves.

## RU CLI Wrappers

| Script | Safety posture |
|---|---|
| `srednoff-os-ru-search.ps1` | Read-only local search |
| `srednoff-os-ru-audit.ps1` | Read-only metadata audit |
| `srednoff-os-ru-import.ps1` | Recommendation-only dry-run command output |
| `srednoff-os-ru-install.ps1` | Blocked without explicit confirmation and review gates |

## NeuralDeep Registry

`registry/neuraldeep/` stores disabled candidate metadata for skills, MCP servers, and CLI tools.

Default guarantees:

- `enabled=false`;
- `auto_install=false`;
- `trusted_for_execution=false`;
- item-level provenance and license review required;
- human confirmation required before enabling or installing anything.

## NeuralDeep Importer

`integrations/neuraldeep/import-neuraldeep-registry.ps1` imports local manifests into disabled metadata only. It does not fetch network catalogs by default and does not install tools.

Use `-DryRun` for review reports before writing registry files.

