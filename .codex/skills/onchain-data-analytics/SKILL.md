---
name: onchain-data-analytics
description: "Use this skill for on-chain data, explorers, Dune-style queries, wallets, transfers, contract events."
---

# Onchain Data Analytics

## Decisions

- Pin chain, block range, finality, token decimals, contract versions, and data source.
- Handle reorgs and duplicate events; reconcile indexed data with raw transactions.

## Acceptance

Report query reproducibility, completeness, precision, and freshness.

## Constraints

- Do not deanonymize individuals or expose sensitive wallet associations without cause.
