---
name: expo-eas-release-gate
description: Use before Expo or React Native app release, EAS build/update, TestFlight, Play Store, App Store, or mobile deployment work.
---

# Expo Eas Release Gate

## Task Decisions

1. Pin SDK/runtime/build profile and verify native dependency compatibility before an EAS build or update.
2. Test the intended device channel and rollback; incompatible native changes require a new binary, not only an OTA update.

Use this skill for Mobile work focused on check Expo/EAS build profiles, channels, updates, app store metadata, release safety, and rollback.

## Guardrails

- Do not perform destructive, paid, production, publishing, account-changing, trading, legal, financial, or externally visible actions without explicit confirmation.
- Do not expose secrets, tokens, cookies, private keys, personal data, or confidential business data.
- Do not copy third-party code or assets without license/provenance review.
- If validation is impossible, state why and provide a concrete manual verification path.
