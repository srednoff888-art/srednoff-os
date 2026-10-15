---
name: core-web-vitals-frontend
description: "Use this skill for LCP, CLS, INP, rendering performance, image/font loading, frontend vitals fixes."
---

# Core Web Vitals Frontend

## Decisions

- Separate field LCP/INP/CLS from lab results and reproduce on representative devices/network profiles.
- Use a trace to identify critical resources, long tasks, layout shifts, and interaction bottlenecks.

## Acceptance

Compare repeated measurements and verify the change does not regress accessibility or functionality.

## Constraints

- Do not trade accessibility or correctness for synthetic scores.
