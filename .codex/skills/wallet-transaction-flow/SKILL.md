---
name: wallet-transaction-flow
description: "Use this skill for wallet UX, transaction signing, gas, chain switching, error states, user safety."
---

# Wallet Transaction Flow

## Decisions

- Show chain, asset, amount, recipient, fees, approvals, and irreversible consequences before signing.
- Handle rejection, wrong chain, pending/failed confirmation, replacement, and disconnect.

## Acceptance

Test on a sandbox/testnet with idempotent state updates; live signing requires authorization.

## Constraints

- Do not request or store seed phrases or private keys.
