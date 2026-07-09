# Srednoff OS Documentation

This directory is the public documentation layer for Srednoff OS v2.1.2.

## Navigation

| Document | Purpose |
|---|---|
| [Architecture](architecture.md) | System map, file ownership, startup flow, selector flow, and release evidence path |
| [Security](security.md) | Hook posture, secret handling, destructive-action gates, provenance, and privacy boundaries |
| [Workflows](workflows.md) | Daily project workflow, system maintenance, release checkpoint workflow, and TURBO boundaries |
| [Profiles](profiles.md) | Public profile layer, local overlays, and old-session sync behavior |
| [RU And NeuralDeep](ru-and-neuraldeep.md) | RU policies, bundles, agents, CLI wrappers, NeuralDeep registry, and importer rules |
| [Risk Model](risk-model.md) | Risk classes, allowed actions, blocked actions, residual risks, and review triggers |
| [Validation](validation.md) | Local and CI release gates, doctor checks, and evidence table |

## Documentation Principles

- Keep startup instructions compact and link to deeper references.
- Document facts that are backed by files, scripts, manifests, or CI evidence.
- Mark unverified external sources as untrusted until provenance and license checks pass.
- Keep personal/local profile state separate from the public repository.
- Treat docs as release evidence: update docs when behavior, gates, or public claims change.

