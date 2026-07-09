# Srednoff OS Checkpoint 10 - RU Specialist Agents

Date: 2026-07-09

## Scope

Checkpoint 10 adds RU specialist agent profiles as compact markdown references.
They are selector metadata and specialist lenses, not autonomous execution units.

## Profiles

- `ru-seo-agent`
- `ru-marketplaces-agent`
- `ru-1c-agent`
- `ru-enterprise-agent`
- `ru-llm-agent`
- `ru-content-agent`
- `ru-payments-agent`
- `ru-messaging-agent`

## Safety Contract

- Agent profiles are disabled by default.
- Agent profiles do not install tools, call connectors, or start subagents by
  themselves.
- Profiles reference existing bundles, policies, and skills.
- RU regulated, paid, production, externally visible, personal-data, payment,
  and messaging actions still require explicit confirmation.

## Validation

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-agents.ps1"
```

