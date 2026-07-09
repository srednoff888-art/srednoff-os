# Risk Model

Srednoff OS uses a conservative risk model: quality improvements are welcome only when safety, provenance, and cost boundaries remain explicit.

## Risk Classes

| Class | Examples | Default |
|---|---|---|
| Low | Read-only searches, local docs, formatting, metadata inspection | Allow |
| Medium | New dependencies, copied components, external source intake, public docs claims | Review |
| High | Secrets, destructive filesystem actions, production changes, auth/RLS, payments, DNS, account changes | Ask or block |
| Critical | Irreversible migrations, data deletion, paid actions, secret publication, security bypass | Block without explicit confirmation |

## Source Risk

| Source type | Risk | Required gate |
|---|---|---|
| Official docs | Low-medium | Check freshness and version |
| Mature open-source repo | Medium | License, activity, dependency, and fit review |
| UI/3D asset marketplace | Medium-high | License, provenance, size, accessibility/performance QA |
| Prompt leak/archive | High | Pattern extraction only, no verbatim reuse |
| MCP/CLI catalog | High | Tool permissions, command side effects, secret exfiltration review |

## Blocked Without Confirmation

- deleting production data;
- committing secrets;
- disabling auth/RLS/security checks;
- executing external installers;
- changing DNS/domain/payment settings;
- irreversible migrations;
- publishing or deploying externally visible changes;
- enabling unreviewed MCP servers or CLI tools.

## Residual Risks

- Selector scoring is heuristic.
- Source ranking does not replace legal review.
- Hooks reduce accidental misuse but are not a sandbox.
- Public forks can become unsafe if users add local secrets.
- Prompt leak repositories may contain vendor-owned text even when repository metadata has an open license.

## Review Triggers

Run deeper review for architecture, production, security, auth, payments, SEO/PPC/growth, crypto, regulated data, external components, MCP/CLI installs, prompt-source mining, and irreversible migrations.

