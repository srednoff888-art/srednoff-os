# Srednoff OS Checkpoint 9 - RU Bundles

Date: 2026-07-09

## Scope

Checkpoint 9 adds compact RU-market bundle metadata for recurring Russian-market
workflows. Bundles are selector hints, not executable tools.

## Bundles

- `ru-seo`
- `ru-marketplaces`
- `ru-enterprise`
- `ru-1c`
- `ru-llm`
- `ru-content`
- `ru-payments`
- `ru-messaging`
- `ru-devops`

## Safety Contract

- Bundles are disabled by default.
- Bundles do not install or enable tools.
- Bundles reference existing policies and skills.
- RU personal data, payments, messaging, marketplace, production, and externally
  visible actions still require human confirmation.
- Legal/regulatory facts remain time-sensitive and must be checked against
  current official sources before production use.

## Validation

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-bundles.ps1"
```

