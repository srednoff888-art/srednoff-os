param(
    [switch]$Rebuild
)

$ErrorActionPreference = "Stop"

$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$SkillRoot = Join-Path $CodexHome "skills\quality-cost-skill-kernel"
$Build = Join-Path $SkillRoot "scripts\build_core_catalog.py"
$Validate = Join-Path $SkillRoot "scripts\validate_core_catalog.py"
$QuickValidate = Join-Path $CodexHome "skills\.system\skill-creator\scripts\quick_validate.py"

if ($Rebuild) {
    python $Build
}

python $Validate
python $QuickValidate $SkillRoot
