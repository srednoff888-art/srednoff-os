---
name: conversion-tracking-gtm-ga4
description: "Use this skill for GTM, GA4, Google Ads conversions, events, consent mode, attribution plumbing."
---

# Conversion Tracking GTM GA4

## Decisions

- Define conversion semantics, consent state, event IDs, currency/value, and client/server ownership.
- Verify deduplication and trigger conditions; test refusal and page reload without real purchase submission.

## Acceptance

Reconcile debug events with received analytics records and state reporting delays.

## Constraints

- Do not add tracking that violates privacy, consent, or platform policy.
