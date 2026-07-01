param(
    [string]$SkillsRoot = "",
    [string]$Validator = "",
    [ValidateSet("fast", "full")]
    [string]$Mode = "fast",
    [int]$MaxFailures = 20
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = (Resolve-Path -LiteralPath (Join-Path $ScriptDir "..")).Path
if (-not $SkillsRoot) {
    $LocalSkillsRoot = Join-Path $PackageRoot ".codex\skills"
    $SkillsRoot = if (Test-Path -LiteralPath $LocalSkillsRoot -PathType Container) { $LocalSkillsRoot } else { "$HOME\.codex\skills" }
}
if (-not $Validator) {
    $Validator = "$HOME\.codex\skills\.system\skill-creator\scripts\quick_validate.py"
}

if (-not (Test-Path -LiteralPath $SkillsRoot)) {
    throw "Skills root not found: $SkillsRoot"
}

$SkillDirs = Get-ChildItem -LiteralPath $SkillsRoot -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") }

$Ok = 0
$Failures = @()
$Timer = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($Skill in $SkillDirs) {
    if ($Mode -eq "fast") {
        $SkillFile = Join-Path $Skill.FullName "SKILL.md"
        $Text = Get-Content -LiteralPath $SkillFile -Raw -Encoding UTF8
        $Lines = $Text -split "`r?`n"
        $NameOk = $false
        $DescriptionOk = $false
        for ($Index = 0; $Index -lt $Lines.Count; $Index++) {
            $Line = $Lines[$Index]
            if ($Line -match '^\s*---\s*$' -and $Index -gt 0) { break }
            if ($Line -match '^\s*name:\s*[a-z0-9][a-z0-9-]{1,62}\s*$') {
                $NameOk = $true
            }
            if ($Line -match '^\s*description:\s*(.+)$') {
                $Value = $Matches[1].Trim()
                if ($Value -in @(">", "|", ">-", "|-", ">+", "|+")) {
                    $BlockLines = @()
                    for ($Child = $Index + 1; $Child -lt $Lines.Count; $Child++) {
                        if ($Lines[$Child] -match '^\s*---\s*$') { break }
                        if ($Lines[$Child] -match '^\s+\S') { $BlockLines += $Lines[$Child].Trim() }
                    }
                    $DescriptionOk = (($BlockLines -join " ").Trim().Length -ge 20)
                } else {
                    $DescriptionOk = ($Value.Trim('"').Trim("'").Length -ge 20)
                }
            }
        }
        $Errors = @()
        if (-not $Text.StartsWith("---")) { $Errors += "missing frontmatter start" }
        if (-not $NameOk) { $Errors += "missing or invalid name" }
        if (-not $DescriptionOk) { $Errors += "missing or too-short description" }
        if ($Errors.Count -eq 0) {
            $Ok++
        } else {
            $Failures += [PSCustomObject]@{
                Skill = $Skill.Name
                Output = ($Errors -join "; ")
            }
        }
    } else {
        if (-not (Test-Path -LiteralPath $Validator)) {
            throw "Validator not found: $Validator"
        }
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

    if ($Failures.Count -ge $MaxFailures) {
        break
    }
}
$Timer.Stop()

Write-Output "validated ok: $Ok"
Write-Output "validated failed: $($Failures.Count)"
Write-Output "mode: $Mode"
Write-Output "elapsed_seconds: $([math]::Round($Timer.Elapsed.TotalSeconds, 2))"

if ($Failures.Count -gt 0) {
    $Failures | Format-List
    exit 1
}
