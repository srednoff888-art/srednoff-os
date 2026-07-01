param(
    [string]$SkillsRoot = "$HOME\.codex\skills",
    [string]$Validator = "$HOME\.codex\skills\.system\skill-creator\scripts\quick_validate.py"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SkillsRoot)) {
    throw "Skills root not found: $SkillsRoot"
}

if (-not (Test-Path -LiteralPath $Validator)) {
    throw "Validator not found: $Validator"
}

$SkillDirs = Get-ChildItem -LiteralPath $SkillsRoot -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") }

$Ok = 0
$Failures = @()

foreach ($Skill in $SkillDirs) {
    $Output = & python $Validator $Skill.FullName 2>&1
    if ($LASTEXITCODE -eq 0) {
        $Ok++
    } else {
        $Failures += [PSCustomObject]@{
            Skill = $Skill.Name
            Output = ($Output -join "`n")
        }
    }
}

Write-Output "validated ok: $Ok"
Write-Output "validated failed: $($Failures.Count)"

if ($Failures.Count -gt 0) {
    $Failures | Format-List
    exit 1
}
