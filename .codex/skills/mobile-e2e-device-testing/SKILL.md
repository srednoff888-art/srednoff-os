---
name: mobile-e2e-device-testing
description: "Verify a mobile application's critical flows on specified devices, OS versions, permissions, lifecycle, and network conditions."
---

# Mobile E2E Device Testing
Choose a device/OS matrix based on users and platform constraints. Identify what an emulator cannot verify.
## Decisions
- Exercise install/upgrade, login, interrupted requests, background/foreground, offline recovery, deep links, and permission refusal.
- Isolate test accounts and stable test data. Keep real purchases, pushes, and production writes outside the test unless requested.
- Record screenshots, logs, device/build identity, and repro steps without user data.
## Acceptance
Report per-device pass/fail, emulator-only gaps, and untested hardware behavior. A desktop responsive preview is not a native-device test.
