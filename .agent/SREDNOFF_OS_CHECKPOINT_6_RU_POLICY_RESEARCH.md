# Checkpoint 6 RU Policy Research

Date: 2026-07-09

## Scope

Add conservative Srednoff OS risk gates for Russian-market data, payments, messaging, marketplaces, and NeuralDeep/source-import work.

These policies are operational safeguards, not legal advice.

## Sources Checked

| Source | Relevance | Pattern adapted |
|---|---|---|
| Roskomnadzor personal-data FAQ | Operator, notification, and personal-data processing concepts | `ru-data` asks for operator, consent/legal basis, retention, transfer review |
| Roskomnadzor localization docs | Personal-data localization risk | `ru-data` requires localization/storage review |
| Bank of Russia National Payment System pages | Payment system/SBP context | `ru-payments` requires provider, payment-data, refund, and live-payment review |
| Bank of Russia SBP pages and FAQ | SBP transfers and settlement behavior | `ru-payments` treats live money movement as confirmation-gated |
| Roskomnadzor messenger notices | Foreign messengers/payment-document and personal-data transfer risk | `ru-messaging` blocks sensitive transfer without review |
| FAS advertising materials and internet ad labeling discussions | Internet ad and ERIR labeling risk | `ru-marketplaces` requires ad-labeling and product-claims review |
| Srednoff checkpoint 0 and operating rules | NeuralDeep API/source uncertainty and external prompt rules | `neuraldeep` stays disabled-by-default with provenance/license/tool review |

## Decision

Adopt:
- default `ask` posture for all RU policy domains;
- explicit `blocked_without_confirmation` lists for risky actions;
- deterministic local fixtures instead of LLM judgment.

Avoid:
- claiming legal compliance;
- installing NeuralDeep/MCP/CLI tools automatically;
- changing production payment, marketplace, or messaging settings without explicit confirmation.

## Validation

`scripts/test-srednoff-os-policies.ps1` verifies required policy files, required fields, no `legal_advice: true`, and fixture-to-policy routing.
