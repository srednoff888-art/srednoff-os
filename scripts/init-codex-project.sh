#!/usr/bin/env bash
set -euo pipefail

timestamp="$(date +%Y%m%d-%H%M%S)"
script_dir="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)"
local_package_root="$(CDPATH='' cd -- "$script_dir/.." && pwd -P)"
codex_home="${CODEX_HOME:-$HOME/.codex}"
global_template_dir="$codex_home/templates/codex-md-os"

if [ -f "$local_package_root/.srednoff-package.json" ] && [ -d "$local_package_root/.codex/skills" ]; then
  template_dir="$local_package_root"
elif [ -f "$global_template_dir/.srednoff-package.json" ]; then
  template_dir="$global_template_dir"
else
  printf '%s\n' 'Clean Srednoff OS distribution template not found; use the distribution init script.' >&2
  exit 1
fi

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

target_input="${1:-.}"
mkdir -p "$target_input"
target_dir="$(CDPATH='' cd -- "$target_input" && pwd -P)"
project_dir="$target_dir"

if git_root="$(git -C "$target_dir" rev-parse --show-toplevel 2>/dev/null)"; then
  git_root="$(CDPATH='' cd -- "$git_root" && pwd -P)"
  home_dir="$(CDPATH='' cd -- "$HOME" && pwd -P)"
  case "$git_root" in
    "$home_dir"|/|[A-Za-z]:/)
      printf 'warning: git root resolved to %s; using requested directory %s instead\n' "$git_root" "$target_dir"
      ;;
    *)
      project_dir="$git_root"
      ;;
  esac
fi

fresh_skills="true"
if [ -d "$project_dir/.codex/skills" ]; then fresh_skills="false"; fi
files=(
  "AGENTS.md"
  "code_review.md"
  ".agent/PLANS.md"
  ".agent/TASK_TEMPLATE.md"
  ".agent/GITHUB_RESEARCH.md"
  ".agent/CONNECTORS.md"
  ".agent/QUALITY_GATE.md"
  ".agent/USER_BRIEFING.md"
  ".agent/SREDNOFF_OS_V2_BACKLOG.md"
  ".agent/SREDNOFF_OS_V2_1_RELEASE.md"
)

for source_dir in "$template_dir/.agent" "$template_dir/.codex/skills" "$template_dir/.codex/srednoff-os" "$template_dir/scripts" "$template_dir/evals" "$template_dir/profiles" "$template_dir/policies" "$template_dir/registry" "$template_dir/integrations" "$template_dir/bundles" "$template_dir/agents" "$template_dir/docs"; do
  if [ -d "$source_dir" ]; then
    while IFS= read -r -d '' file; do
      files+=("${file#"$template_dir/"}")
    done < <(find "$source_dir" -type f ! -path '*/__pycache__/*' ! -name '*.bak.*' ! -name '*.pyc' ! -name '*.log' -print0)
  fi
done

if command -v python3 >/dev/null 2>&1; then
  python_cmd="python3"
else
  python_cmd="python"
fi
compact_mode="false"
compact_marker="$project_dir/.codex/srednoff-os/discovery-profile.json"
if [ -f "$compact_marker" ]; then
  compact_mode="$("$python_cmd" -c 'import json,sys; print(str(json.load(open(sys.argv[1], encoding="utf-8-sig")).get("mode") == "compact").lower())' "$compact_marker")"
fi

created=0
updated=0
skipped=0
missing=0

for rel in "${files[@]}"; do
  src="$template_dir/$rel"
  dst="$project_dir/$rel"
  if [ "$compact_mode" = "true" ]; then
    case "$rel" in
      .codex/skills/github-research/*|.codex/skills/product-builder/*|.codex/skills/production-review/*|.codex/skills/quality-cost-skill-kernel/*) ;;
      .codex/skills/*) dst="$project_dir/.codex/srednoff-os/library/${rel#'.codex/skills/'}" ;;
    esac
  fi

  if [ ! -f "$src" ]; then
    printf 'missing template: %s\n' "$rel"
    missing=$((missing + 1))
    continue
  fi

  mkdir -p "$(dirname -- "$dst")"

  if [ -e "$dst" ]; then
    if cmp -s "$src" "$dst"; then
      printf 'skipped unchanged: %s\n' "$rel"
      skipped=$((skipped + 1))
      continue
    fi

    backup="${dst}.bak.${timestamp}"
    cp -R "$dst" "$backup"
    cp "$src" "$dst"
    printf 'updated with backup: %s -> %s\n' "$rel" "$backup"
    updated=$((updated + 1))
  else
    cp "$src" "$dst"
    printf 'created: %s\n' "$rel"
    created=$((created + 1))
  fi
done

chmod +x "$project_dir/scripts/init-codex-project.sh" "$project_dir/scripts/install-codex-md-os.sh" 2>/dev/null || true

project_skills_root="$project_dir/.codex/skills"
project_skill_index="$project_dir/.codex/skill-index.json"
project_skill_index_script="$project_dir/scripts/generate-skill-index.ps1"
template_skill_index_script="$template_dir/scripts/generate-skill-index.ps1"
if [ -f "$project_skill_index_script" ]; then
  skill_index_script="$project_skill_index_script"
else
  skill_index_script="$template_skill_index_script"
fi

if command -v python3 >/dev/null 2>&1; then
  python_cmd="python3"
else
  python_cmd="python"
fi

if [ -f "$skill_index_script" ] && [ -d "$project_skills_root" ] && powershell_cmd="$(find_powershell)"; then
  if [ -f "$project_skill_index" ]; then
    cp "$project_skill_index" "$project_skill_index.bak.$timestamp"
  fi
  "$powershell_cmd" -NoProfile -ExecutionPolicy Bypass -File "$skill_index_script" -SkillsRoot "$project_skills_root" -OutputPath "$project_skill_index" -RelativePaths -RelativeBase "$project_dir"
else
  "$python_cmd" "$template_dir/scripts/skill_catalog.py" index --skills-root "$project_skills_root" --relative-base "$project_dir" --output "$project_skill_index"
fi

"$python_cmd" "$template_dir/scripts/skill_catalog.py" profile --skills-root "$template_dir/.codex/skills" --project "$project_dir" --brief "${2:-}" --max-skills 12 --install
if [ "$fresh_skills" = "true" ] && [ "${SREDNOFF_LEGACY_DISCOVERY:-0}" != "1" ]; then
  "$python_cmd" "$template_dir/scripts/compact_skill_discovery.py" --package "$template_dir" --previous-package "$template_dir" --active-root "$project_skills_root" --apply
fi

cat <<EOF

Srednoff OS initialized in:
  $project_dir

Summary:
  created: $created
  updated: $updated
  skipped: $skipped
  missing templates: $missing
EOF

status_script="$codex_home/scripts/srednoff-os-status.ps1"
if [ -f "$status_script" ] && powershell_cmd="$(find_powershell)"; then
  "$powershell_cmd" -ExecutionPolicy Bypass -File "$status_script" -ProjectPath "$project_dir"
elif [ -f "$status_script" ]; then
  printf 'skip status check: PowerShell not found\n'
fi
