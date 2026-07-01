param(
    [string[]]$ProjectPath = @("."),
    [string]$TemplateRoot = "$HOME\.codex\templates\codex-md-os",
    [switch]$IncludeScripts
)

$ErrorActionPreference = "Stop"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$SourceSkills = Join-Path $TemplateRoot ".codex\skills"
$SourceSrednoff = Join-Path $TemplateRoot ".codex\srednoff-os"
$SourceScripts = Join-Path $TemplateRoot "scripts"
$SourceEvals = Join-Path $TemplateRoot "evals"

if (-not (Test-Path -LiteralPath $SourceSkills)) {
    throw "Template skills directory not found: $SourceSkills"
}

function Resolve-ProjectRoot {
    param([string]$Path)

    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    $Resolved = (Resolve-Path $Path).Path

    try {
        $GitRootRaw = git -C $Resolved rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $GitRootRaw) {
            $GitRoot = (Resolve-Path $GitRootRaw).Path
            $HomeDir = (Resolve-Path $HOME).Path
            if ($GitRoot -ne $HomeDir -and $GitRoot -notmatch '^[A-Za-z]:\\?$') {
                return $GitRoot
            }
        }
    } catch {
        return $Resolved
    }

    return $Resolved
}

function Copy-SafeFile {
    param(
        [string]$Source,
        [string]$Destination
    )

    $Parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Force -Path $Parent | Out-Null

    if (Test-Path -LiteralPath $Destination) {
        $SourceHash = (Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash
        $DestinationHash = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash

        if ($SourceHash -eq $DestinationHash) {
            return "skipped"
        }

        Copy-Item -LiteralPath $Destination -Destination "$Destination.bak.$Timestamp" -Force
        Copy-Item -LiteralPath $Source -Destination $Destination -Force
        return "updated"
    }

    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    return "created"
}

$Summary = [ordered]@{
    Projects = 0
    Created = 0
    Updated = 0
    Skipped = 0
}

foreach ($Project in $ProjectPath) {
    $Root = Resolve-ProjectRoot -Path $Project
    $Summary.Projects++
    Write-Output "Project: $Root"

    $Files = Get-ChildItem -LiteralPath $SourceSkills -Recurse -File
    foreach ($ExtraDirectory in @($SourceSrednoff, $SourceEvals)) {
        if (Test-Path -LiteralPath $ExtraDirectory) {
            $Files += Get-ChildItem -LiteralPath $ExtraDirectory -Recurse -File
        }
    }
    if ($IncludeScripts -and (Test-Path -LiteralPath $SourceScripts)) {
        $Files += Get-ChildItem -LiteralPath $SourceScripts -Recurse -File
    }

    foreach ($File in $Files) {
        $Base = if ($File.FullName.StartsWith($SourceSkills)) {
            $SourceSkills
        } elseif ($File.FullName.StartsWith($SourceSrednoff)) {
            $SourceSrednoff
        } elseif ($File.FullName.StartsWith($SourceEvals)) {
            $SourceEvals
        } else {
            $SourceScripts
        }
        $Relative = $File.FullName.Substring($Base.Length + 1)
        $DestinationPrefix = if ($Base -eq $SourceSkills) {
            ".codex\skills"
        } elseif ($Base -eq $SourceSrednoff) {
            ".codex\srednoff-os"
        } elseif ($Base -eq $SourceEvals) {
            "evals"
        } else {
            "scripts"
        }
        $Destination = Join-Path (Join-Path $Root $DestinationPrefix) $Relative
        $Result = Copy-SafeFile -Source $File.FullName -Destination $Destination
        $Summary[$Result.Substring(0,1).ToUpper() + $Result.Substring(1)]++
    }

    $ProjectSkillsRoot = Join-Path $Root ".codex\skills"
    $ProjectSkillIndex = Join-Path $Root ".codex\skill-index.json"
    $ProjectSkillIndexScript = Join-Path $Root "scripts\generate-skill-index.ps1"
    $TemplateSkillIndexScript = Join-Path $TemplateRoot "scripts\generate-skill-index.ps1"
    $SkillIndexScript = if (Test-Path -LiteralPath $ProjectSkillIndexScript -PathType Leaf) { $ProjectSkillIndexScript } else { $TemplateSkillIndexScript }
    if ((Test-Path -LiteralPath $SkillIndexScript -PathType Leaf) -and (Test-Path -LiteralPath $ProjectSkillsRoot -PathType Container)) {
        if (Test-Path -LiteralPath $ProjectSkillIndex -PathType Leaf) {
            Copy-Item -LiteralPath $ProjectSkillIndex -Destination "$ProjectSkillIndex.bak.$Timestamp" -Force
        }
        powershell -NoProfile -ExecutionPolicy Bypass -File $SkillIndexScript -SkillsRoot $ProjectSkillsRoot -OutputPath $ProjectSkillIndex -RelativePaths -RelativeBase $Root | Out-Host
    }
}

Write-Output ""
Write-Output "Summary:"
$Summary.GetEnumerator() | ForEach-Object { Write-Output "  $($_.Key): $($_.Value)" }
