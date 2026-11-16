param(
    [string]$ProjectPath = ".",
    [string]$Brief = "",
    [ValidateRange(1, 48)]
    [int]$MaxSkills = 12,
    [switch]$SkipNativeSkills,
    [switch]$LegacyDiscovery
)

$ErrorActionPreference = "Stop"

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LocalPackageRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$GlobalTemplateDir = Join-Path $CodexHome "templates\codex-md-os"
$LocalTemplateReady = (Test-Path -LiteralPath (Join-Path $LocalPackageRoot ".srednoff-package.json") -PathType Leaf) -and (Test-Path -LiteralPath (Join-Path $LocalPackageRoot ".codex\skills") -PathType Container)
$TemplateDir = if ($LocalTemplateReady) { $LocalPackageRoot } elseif (Test-Path -LiteralPath (Join-Path $GlobalTemplateDir ".srednoff-package.json")) { $GlobalTemplateDir } else { throw "Clean Srednoff OS distribution template not found; use the distribution's init script or install/update the global template." }

New-Item -ItemType Directory -Force -Path $ProjectPath | Out-Null
$TargetDir = (Resolve-Path $ProjectPath).Path
$ProjectDir = $TargetDir

try {
    $GitRootRaw = git -C $TargetDir rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0 -and $GitRootRaw) {
        $GitRoot = (Resolve-Path $GitRootRaw).Path
        $HomeDir = (Resolve-Path $HOME).Path
        if ($GitRoot -eq $HomeDir -or $GitRoot -match '^[A-Za-z]:\\?$') {
            Write-Output "warning: git root resolved to $GitRoot; using requested directory $TargetDir instead"
        } else {
            $ProjectDir = $GitRoot
        }
    }
} catch {
    $ProjectDir = $TargetDir
}

$FreshSkillLibrary = -not (Test-Path -LiteralPath (Join-Path $ProjectDir ".codex\skills"))
$Files = @(
    "AGENTS.md",
    "code_review.md"
)

foreach ($Directory in @(".agent", ".codex\skills", ".codex\srednoff-os", "scripts", "evals", "profiles", "policies", "registry", "integrations", "bundles", "agents", "docs")) {
    $SourceDirectory = Join-Path $TemplateDir $Directory
    if (Test-Path -LiteralPath $SourceDirectory) {
        $Files += Get-ChildItem -LiteralPath $SourceDirectory -Recurse -File |
            ForEach-Object { $_.FullName.Substring($TemplateDir.Length + 1) }
    }
}

$Files = $Files | Where-Object { $_ -notmatch '__pycache__|\.bak\.|\.(pyc|log)$' } | Select-Object -Unique
$CompactMarker = Join-Path $ProjectDir ".codex\srednoff-os\discovery-profile.json"
$CompactMode = (Test-Path -LiteralPath $CompactMarker) -and ((Get-Content -LiteralPath $CompactMarker -Raw | ConvertFrom-Json).mode -eq "compact")
$DiscoveryAnchors = @("github-research", "product-builder", "production-review", "quality-cost-skill-kernel")

$Created = 0
$Updated = 0
$Skipped = 0
$Missing = 0

foreach ($RelativePath in $Files) {
    $Source = Join-Path $TemplateDir $RelativePath
    $Destination = Join-Path $ProjectDir $RelativePath
    if ($CompactMode -and $RelativePath -match '^\.codex[\\/]skills[\\/]([^\\/]+)[\\/](.+)$' -and $Matches[1] -notin $DiscoveryAnchors) {
        $Destination = Join-Path $ProjectDir (".codex\srednoff-os\library\" + $Matches[1] + "\" + $Matches[2])
    }

    if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
        Write-Output "missing template: $RelativePath"
        $Missing++
        continue
    }

    $Parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Force -Path $Parent | Out-Null

    if (Test-Path -LiteralPath $Destination) {
        $SourceHash = (Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash
        $DestinationHash = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash

        if ($SourceHash -eq $DestinationHash) {
            Write-Output "skipped unchanged: $RelativePath"
            $Skipped++
            continue
        }

        $Backup = "$Destination.bak.$Timestamp"
        Copy-Item -LiteralPath $Destination -Destination $Backup -Force
        Copy-Item -LiteralPath $Source -Destination $Destination -Force
        Write-Output "updated with backup: $RelativePath -> $Backup"
        $Updated++
    } else {
        Copy-Item -LiteralPath $Source -Destination $Destination -Force
        Write-Output "created: $RelativePath"
        $Created++
    }
}

Write-Output ""
Write-Output "Srednoff OS initialized in:"
Write-Output "  $ProjectDir"
Write-Output ""
Write-Output "Summary:"
Write-Output "  created: $Created"
Write-Output "  updated: $Updated"
Write-Output "  skipped: $Skipped"
Write-Output "  missing templates: $Missing"

$ProjectSkillsRoot = Join-Path $ProjectDir ".codex\skills"
$ProjectSkillIndex = Join-Path $ProjectDir ".codex\skill-index.json"
$ProjectSkillIndexScript = Join-Path $ProjectDir "scripts\generate-skill-index.ps1"
$TemplateSkillIndexScript = Join-Path $TemplateDir "scripts\generate-skill-index.ps1"
$SkillIndexScript = if (Test-Path -LiteralPath $ProjectSkillIndexScript -PathType Leaf) { $ProjectSkillIndexScript } else { $TemplateSkillIndexScript }
if ((Test-Path -LiteralPath $SkillIndexScript -PathType Leaf) -and (Test-Path -LiteralPath $ProjectSkillsRoot -PathType Container)) {
    if (Test-Path -LiteralPath $ProjectSkillIndex -PathType Leaf) {
        Copy-Item -LiteralPath $ProjectSkillIndex -Destination "$ProjectSkillIndex.bak.$Timestamp" -Force
    }
    & $SkillIndexScript -SkillsRoot $ProjectSkillsRoot -OutputPath $ProjectSkillIndex -RelativePaths -RelativeBase $ProjectDir | Out-Host
}

if (-not $SkipNativeSkills) {
    $ProfileScript = Join-Path $TemplateDir "scripts\skill_catalog.py"
    & python $ProfileScript profile --skills-root (Join-Path $TemplateDir ".codex\skills") --project $ProjectDir "--brief=$Brief" --max-skills $MaxSkills --install
    if ($LASTEXITCODE -ne 0) { throw "Native skill deployment failed; user files were preserved." }
}

if ($FreshSkillLibrary -and -not $LegacyDiscovery) {
    & python (Join-Path $TemplateDir "scripts\compact_skill_discovery.py") --package $TemplateDir --previous-package $TemplateDir --active-root $ProjectSkillsRoot --apply
    if ($LASTEXITCODE -ne 0) { throw "Fresh compact discovery setup failed; no manifests were deleted." }
}

$StatusScript = Join-Path $CodexHome "scripts\srednoff-os-status.ps1"
if (Test-Path -LiteralPath $StatusScript) {
    & $StatusScript -ProjectPath $ProjectDir
}
