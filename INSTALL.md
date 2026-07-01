# Install Srednoff OS

## 1. Clone

```bash
git clone https://github.com/srednoff888-art/srednoff-os.git
cd srednoff-os
```

## 2. Install The Template

PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\install-codex-md-os.ps1"
```

Bash:

```bash
chmod +x ./scripts/*.sh
./scripts/install-codex-md-os.sh
```

## 3. Initialize A Project

PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\templates\codex-md-os\scripts\init-codex-project.ps1" "C:\path\to\project"
```

Bash:

```bash
"$HOME/.codex/templates/codex-md-os/scripts/init-codex-project.sh" "/path/to/project"
```

## 4. Optional Hooks

Copy `hooks.example.json` into your Codex home as `hooks.json`, then edit the command paths if needed.

PowerShell:

```powershell
Copy-Item ".\hooks.example.json" "$HOME\.codex\hooks.json"
```

Never commit your real `config.toml`, `hooks.state`, `.env`, connector API keys, or token files.

## 5. Validate

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\scripts\srednoff-os-doctor.ps1" -ProjectPath "C:\path\to\project" -RunEvals -FixSafe
```
