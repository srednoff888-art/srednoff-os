---
name: animation-scroll-performance
description: "Use this skill for scroll effects, animation budget, jank diagnosis, reduced motion, frame timing."
---

# Animation Scroll Performance

## Task Decisions

1. Profile a fixed scroll sequence and identify layout/paint work versus compositor animation before changing the timeline.
2. Respect reduced motion and visibility; test on a slower device and preserve readable content when animation is disabled.

Use this skill for Web Design tasks focused on scroll effects, animation budget, jank diagnosis, reduced motion, frame timing.

## Guardrails

- Do not ship scroll-jacking or motion that impairs navigation.
- Do not perform destructive, paid, production, publishing, account-changing, or externally visible actions without explicit user confirmation.
- Do not expose secrets, private keys, tokens, cookies, private analytics, personal data, or confidential business data.
- If validation is impossible, state why and provide a concrete manual verification path.
