---
name: android-jetpack-compose-builder
description: "Use this skill for Android Jetpack Compose, Material, navigation, state, build/release workflows."
---

# Android Jetpack Compose Builder

## Decisions

- Keep UI state immutable and lifecycle-aware; map events through the existing ViewModel/navigation architecture.
- Handle recomposition, saved state, accessibility semantics, edge-to-edge insets, and process recreation.

## Acceptance

Run previews plus device tests for rotation, background recovery, keyboard, and permission denial.

## Constraints

- Do not ignore Android lifecycle and permission behavior.
