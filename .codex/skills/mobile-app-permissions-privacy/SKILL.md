---
name: mobile-app-permissions-privacy
description: "Use this skill for mobile permissions, privacy labels, data collection, consent, OS permission prompts."
---

# Mobile App Permissions Privacy

## Decisions

- Map each permission to a real feature and the platform's current access requirement.
- Request permission in context and provide useful refusal/revocation behavior; minimize collected data.

## Acceptance

Test denied/revoked permissions on devices and reconcile declared privacy labels.

## Constraints

- Do not request permissions before explaining user value.
