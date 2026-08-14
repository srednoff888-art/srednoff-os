---
name: agents-sdk-production-workflow
description: Use this skill when designing, reviewing, debugging, or productionizing OpenAI Agents SDK, Responses API, or similar agent systems with tools, handoffs, guardrails, tracing, evals, human approval, retries, and deployment safety.
---

# Agents SDK Production Workflow

Build agent systems as explicit workflows with observable state, typed boundaries, and human review for risky actions.

## Workflow

1. Define the user outcome, risk level, and allowed autonomous actions.
2. Choose orchestration shape: single agent, deterministic pipeline, supervisor, handoff graph, or planner/executor/reviewer.
3. Define every tool contract with typed inputs, least privilege, timeouts, idempotency, and redacted logs.
4. Add guardrails before irreversible actions: input validation, output schema checks, policy checks, confirmation gates, and rate limits.
5. Add tracing around model calls, tool calls, handoffs, retries, errors, cost, latency, and user-visible decisions.
6. Build evals from real tasks: golden cases, adversarial cases, tool failure cases, and regression thresholds.
7. Add fallback behavior: no-op, partial result, queue for human review, or deterministic implementation.
8. Validate locally with mocked tools before touching live APIs, billing, production data, emails, trades, or deployments.
9. Pin the Agents SDK, OpenAI client, MCP SDK major, and model explicitly. Review release notes before upgrades because implicit model defaults and transport-owned types can change in minor releases.
10. Treat interrupted runs as durable state transitions. Stage new input only at the documented resume boundary, bind approvals to the canonical tool invocation, preserve structured tool and guardrail state, and reject unsafe replay unless a reviewed application policy explicitly allows it.
11. Fail closed on sandbox credential mounts. Acknowledge the exact effective in-container path only when exposure is required, keep credentials out of serialized state, and re-authorize mount authority after restore.

## OpenAI Agents SDK 2026-08-11 Gate

- Python v0.20.0 and TypeScript v0.15.0 changed the implicit default model to gpt-5.6-luna; production workflows should set and regression-test the intended model instead of inheriting a release default.
- Python v0.20.0 supports MCP Python SDK v1 and v2, while TypeScript v0.15.0 uses the MCP TypeScript SDK v2 client with legacy-server fallback. Custom HTTP auth/client factories must use types owned by the installed MCP major; do not bridge or mix majors by accident.
- Serialize paused RunState with a versioned compatibility envelope. Test pending input, repeated interruptions, structured tool output, guardrail state, approval identity, cancellation, and restore across the supported application versions.
- Keep approveUnsafeReplay or equivalent escape hatches application-controlled, off by default, audited, and unavailable to model instructions or untrusted tool output.
- Bound strict JSON Schema recursion and validation work, and redact validation errors before logging or returning them across a trust boundary.

## Design Checklist

- Prefer deterministic code for parsing, routing, validation, and data transforms.
- Keep model prompts small and task-specific; move durable policy into code or skills.
- Use structured outputs for decisions that drive tools or persistence.
- Separate planner, executor, verifier, and user-communication responsibilities when a task spans multiple steps.
- Treat handoffs as typed state transitions, not vague "ask another agent" prompts.
- Store only necessary traces; redact secrets, tokens, cookies, PII, and regulated data.
- Add budget caps for tokens, wall time, retries, tool calls, and paid API actions.
- Version prompts, tool schemas, eval datasets, and production config together.
- Pin and test the model rather than relying on a mutable SDK default.
- Keep resumable state versioned, integrity-checked, principal-bound, and free of reusable credentials.
- Cover mixed MCP SDK majors and custom transport/auth factories with explicit compatibility fixtures.

## Review Questions

- What can the agent do without human approval?
- What happens when a tool returns stale, partial, malicious, or malformed data?
- Which actions are irreversible or expensive?
- Which eval would fail if the next model release changes behavior?
- Can a production incident be reconstructed from traces without exposing secrets?

## Guardrails

- Do not let an LLM decide legal, medical, financial, hiring, trading, security, or compliance outcomes without human review.
- Do not grant broad filesystem, network, database, email, deployment, billing, or admin tools when narrow tools are enough.
- Do not log raw prompts or tool payloads when they may contain secrets or personal data.
- Do not deploy an agent workflow without tests for tool failures, prompt injection, and schema violations.
- Do not trust a serialized approval, replay decision, or credential-bearing mount after restore without re-validating its canonical identity and current authorization.
