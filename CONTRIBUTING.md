# Contributing to Srednoff OS

Thanks for improving Srednoff OS.

## Good Contributions

- new portable skills with clear trigger rules;
- selector improvements that reduce wasted context;
- safety checks for secrets, destructive actions, or production changes;
- better documentation, examples, and onboarding;
- bug fixes in install, sync, status, doctor, router, or selector scripts.

## Contribution Rules

- Do not commit real `.env` files, API keys, tokens, cookies, connector env values, private Codex config, or local hook state.
- Do not add machine-specific absolute paths.
- Keep skills compact. A skill should load only the instructions it needs.
- Prefer reusable patterns over copied third-party code.
- Include validation steps in every PR.

## Local Checks

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\quick-validate-all-skills.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-selector.ps1"
powershell -ExecutionPolicy Bypass -File ".\scripts\test-srednoff-os-v212.ps1"
```

## Pull Request Checklist

- [ ] The change is portable across machines.
- [ ] No secrets or private local state are included.
- [ ] New or changed skills pass validation.
- [ ] README or install docs are updated when behavior changes.
- [ ] The PR explains what was tested.
