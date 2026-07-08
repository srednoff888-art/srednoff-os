# Srednoff OS Profiles

Profiles are small configuration overlays for Srednoff OS behavior. They keep the public core portable while allowing local users, agencies, or regional teams to apply their own defaults.

## Profiles

| Profile | Purpose | Default |
|---|---|---:|
| `public-default` | Safe public behavior for shared repositories and first install | yes |
| `ivan` | Sanitized maintainer example; private values must stay local | no |
| `agency` | Client-service workflow defaults for agency projects | no |
| `ru-market` | Russian-market workflow defaults with stronger policy awareness | no |

## Boundary

The public repository may contain only portable profile metadata:

- profile name and description;
- recommended modes;
- domains and validation gates;
- links to public Srednoff OS rules;
- no secrets, local paths, connector state, private client names, or machine-specific settings.

Private overlays belong outside the public repository, for example:

```powershell
$HOME\.codex\profiles\ivan.local.json
```

Use `scripts\srednoff-os-profile.ps1` to list or inspect public profiles.
