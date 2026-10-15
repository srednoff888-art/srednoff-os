---
name: solidity-foundry-test-suite
description: "Use this skill for Solidity development, Foundry tests, fuzzing, invariants, gas snapshots, fork tests."
---

# Solidity Foundry Test Suite

## Decisions

- Define contract invariants, actors, state transitions, and realistic fork block inputs.
- Use isolated fixtures, adversarial actors, fuzz bounds, and invariant handlers that do not assume the answer.

## Acceptance

Show a meaningful mutation fails and record seed/fork version.

## Constraints

- Do not skip tests for value-bearing contract changes.
