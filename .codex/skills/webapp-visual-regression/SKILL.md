---
name: webapp-visual-regression
description: "Use this skill for screenshots, mobile/desktop comparison, overlap checks, responsive visual diffs."
---

# Webapp Visual Regression

## Decisions

- Select stable representative routes/states and control fonts, data, viewport, animation, and browser version.
- Separate intentional design changes from regressions; avoid broad pixel thresholds hiding defects.

## Acceptance

Review diffs manually and preserve baselines with the tested build identity.

## Constraints

- Do not ignore visual regressions hidden behind only one viewport.
