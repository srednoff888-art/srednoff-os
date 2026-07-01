#!/usr/bin/env bash
set -euo pipefail

timestamp="$(date +%Y%m%d-%H%M%S)"
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
package_root="$(CDPATH= cd -- "$script_dir/.." && pwd -P)"
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

mkdir -p "$codex_home" "$template_dir"

copy_item "AGENTS.md"
copy_item "code_review.md"
copy_item ".agent"
copy_item ".codex/skills"
copy_item "scripts"

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

cat <<EOF

Codex MD OS installed.

Add it to a project:
  $template_dir/scripts/init-codex-project.sh /path/to/project

Optional alias:
  alias codex-init='$template_dir/scripts/init-codex-project.sh'
EOF
