---
name: agent-model-upgrade-evals
description: "Adapt an existing agent skill or workflow to a new model/runtime and verify outcome quality, triggering, tool compatibility, and measured context cost."
---

# Agent Model Upgrade Evals

Preserve the user's requested model and runtime. Resolve unspecified current targets from official documentation and installed host capabilities.

## Decisions

- Pin model identity, runtime version, skill revision, permissions, input corpus, and grading rules for each comparison.
- Separate metadata/trigger checks from actual task completion. Include unrelated negative prompts and held-out examples whose answers are unavailable to the agent.
- Remove redundant instructions only after checking their original purpose; keep fragile data, permission, and tool-contract invariants.
- Test each supported model separately. Record incomplete runs, timeouts, cached input, and observed tokens without calling them money or ROI.

## Acceptance

Compare task artifacts and traces against deterministic requirements, then apply a reviewer rubric for subjective quality. Publish the corpus, tool versions, conditions, failures, and coverage gaps. Do not infer a model win from structural lint or a selector match.
