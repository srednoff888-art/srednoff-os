param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LocalPackageRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$GlobalTemplateDir = Join-Path $CodexHome "templates\codex-md-os"
$LocalTemplateReady = (Test-Path -LiteralPath (Join-Path $LocalPackageRoot "AGENTS.md") -PathType Leaf) -and (Test-Path -LiteralPath (Join-Path $LocalPackageRoot ".codex\skills") -PathType Container)
$TemplateDir = if ($LocalTemplateReady) { $LocalPackageRoot } elseif (Test-Path -LiteralPath $GlobalTemplateDir) { $GlobalTemplateDir } else { $LocalPackageRoot }

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

$Files = @(
    "AGENTS.md",
    "code_review.md"
)

foreach ($Directory in @(".agent", ".codex\skills", ".codex\srednoff-os", "scripts", "evals", "profiles")) {
    $SourceDirectory = Join-Path $TemplateDir $Directory
    if (Test-Path -LiteralPath $SourceDirectory) {
        $Files += Get-ChildItem -LiteralPath $SourceDirectory -Recurse -File |
            ForEach-Object { $_.FullName.Substring($TemplateDir.Length + 1) }
    }
}

$Files = $Files | Select-Object -Unique

$Created = 0
$Updated = 0
$Skipped = 0
$Missing = 0

foreach ($RelativePath in $Files) {
    $Source = Join-Path $TemplateDir $RelativePath
    $Destination = Join-Path $ProjectDir $RelativePath

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

$StatusScript = Join-Path $CodexHome "scripts\srednoff-os-status.ps1"
if (Test-Path -LiteralPath $StatusScript) {
    & $StatusScript -ProjectPath $ProjectDir
}
