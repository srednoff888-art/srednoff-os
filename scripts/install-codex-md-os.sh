#!/usr/bin/env bash
set -euo pipefail

timestamp="$(date +%Y%m%d-%H%M%S)"
script_dir="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)"
package_root="$(CDPATH='' cd -- "$script_dir/.." && pwd -P)"
codex_home="${CODEX_HOME:-$HOME/.codex}"
template_dir="$codex_home/templates/codex-md-os"

backup_path() {
  local path="$1"
  if [ -e "$path" ]; then
    local backup="${path}.bak.${timestamp}"
    cp -R "$path" "$backup"
    printf 'backup: %s -> %s\n' "$path" "$backup"
  fi
}

find_powershell() {
  if command -v pwsh >/dev/null 2>&1; then
    printf '%s\n' "pwsh"
    return 0
  fi
  if command -v powershell >/dev/null 2>&1; then
    printf '%s\n' "powershell"
    return 0
  fi
  return 1
}

copy_item() {
  local rel="$1"
  local src="$package_root/$rel"
  local dst="$template_dir/$rel"

  if [ ! -e "$src" ]; then
    printf 'skip missing source: %s\n' "$src"
    return 0
  fi

  mkdir -p "$(dirname -- "$dst")"
  backup_path "$dst"
  cp -R "$src" "$dst"
  printf 'installed template: %s\n' "$rel"
}

copy_dir_contents() {
  local src="$1"
  local dst="$2"
  local label="$3"

  if [ ! -d "$src" ]; then
    printf 'skip missing source: %s\n' "$src"
    return 0
  fi

  backup_path "$dst"
  mkdir -p "$dst"
  cp -R "$src"/. "$dst"/
  printf 'installed global: %s -> %s\n' "$label" "$dst"
}

mkdir -p "$codex_home" "$template_dir"

copy_item "AGENTS.md"
copy_item "code_review.md"
copy_item ".agent"
copy_item ".codex/skills"
copy_item ".codex/skill-index.json"
copy_item ".codex/srednoff-os"
copy_item "evals"
copy_item "profiles"
copy_item "policies"
copy_item "registry"
copy_item "integrations"
copy_item "scripts"

copy_dir_contents "$package_root/.codex/skills" "$codex_home/skills" "skills"
copy_dir_contents "$package_root/.codex/srednoff-os" "$codex_home/srednoff-os" "srednoff-os"
copy_dir_contents "$package_root/scripts" "$codex_home/scripts" "scripts"
copy_dir_contents "$package_root/evals" "$codex_home/evals" "evals"
copy_dir_contents "$package_root/profiles" "$codex_home/profiles" "profiles"
copy_dir_contents "$package_root/policies" "$codex_home/policies" "policies"
copy_dir_contents "$package_root/registry" "$codex_home/registry" "registry"
copy_dir_contents "$package_root/integrations" "$codex_home/integrations" "integrations"

backup_path "$codex_home/AGENTS.md"
cp "$package_root/AGENTS.md" "$codex_home/AGENTS.md"
printf 'installed global: %s\n' "$codex_home/AGENTS.md"

if [ -f "$package_root/code_review.md" ]; then
  backup_path "$codex_home/code_review.md"
  cp "$package_root/code_review.md" "$codex_home/code_review.md"
  printf 'installed global: %s\n' "$codex_home/code_review.md"
fi

chmod +x "$package_root/scripts/init-codex-project.sh" "$package_root/scripts/install-codex-md-os.sh" 2>/dev/null || true
chmod +x "$template_dir/scripts/init-codex-project.sh" "$template_dir/scripts/install-codex-md-os.sh" 2>/dev/null || true

if [ -f "$package_root/scripts/generate-skill-index.ps1" ] && powershell_cmd="$(find_powershell)"; then
  "$powershell_cmd" -NoProfile -ExecutionPolicy Bypass -File "$package_root/scripts/generate-skill-index.ps1" -SkillsRoot "$codex_home/skills" -OutputPath "$codex_home/skill-index.json"
else
  printf 'skip skill index generation: PowerShell not found\n'
fi

cat <<EOF

Codex MD OS installed.

Add it to a project:
  $template_dir/scripts/init-codex-project.sh /path/to/project

Optional alias:
  alias codex-init='$template_dir/scripts/init-codex-project.sh'
EOF
