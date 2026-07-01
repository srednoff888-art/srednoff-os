$ErrorActionPreference = "Stop"

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$TemplateDir = Join-Path $CodexHome "templates\codex-md-os"

function Backup-Path {
    param([Parameter(Mandatory=$true)][string]$Path)

    if (Test-Path -LiteralPath $Path) {
        $Backup = "$Path.bak.$Timestamp"
        Copy-Item -LiteralPath $Path -Destination $Backup -Recurse -Force
        Write-Output "backup: $Path -> $Backup"
    }
}

function Copy-TemplateItem {
    param([Parameter(Mandatory=$true)][string]$RelativePath)

    $Source = Join-Path $PackageRoot $RelativePath
    $Destination = Join-Path $TemplateDir $RelativePath

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Output "skip missing source: $Source"
        return
    }

    $Parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Force -Path $Parent | Out-Null
    Backup-Path -Path $Destination
    Copy-Item -LiteralPath $Source -Destination $Parent -Recurse -Force
    Write-Output "installed template: $RelativePath"
}

New-Item -ItemType Directory -Force -Path $CodexHome, $TemplateDir | Out-Null

Copy-TemplateItem "AGENTS.md"
Copy-TemplateItem "code_review.md"
Copy-TemplateItem ".agent"
Copy-TemplateItem ".codex\skills"
Copy-TemplateItem "scripts"

$GlobalAgents = Join-Path $CodexHome "AGENTS.md"
Backup-Path -Path $GlobalAgents
Copy-Item -LiteralPath (Join-Path $PackageRoot "AGENTS.md") -Destination $GlobalAgents -Force
Write-Output "installed global: $GlobalAgents"

$GlobalCodeReview = Join-Path $CodexHome "code_review.md"
$LocalCodeReview = Join-Path $PackageRoot "code_review.md"
if (Test-Path -LiteralPath $LocalCodeReview) {
    Backup-Path -Path $GlobalCodeReview
    Copy-Item -LiteralPath $LocalCodeReview -Destination $GlobalCodeReview -Force
    Write-Output "installed global: $GlobalCodeReview"
}

Write-Output ""
Write-Output "Codex MD OS installed."
Write-Output ""
Write-Output "Add it to a project:"
Write-Output "  powershell -ExecutionPolicy Bypass -File `"$TemplateDir\scripts\init-codex-project.ps1`" C:\path\to\project"
Write-Output ""
Write-Output "Optional bash-compatible command:"
Write-Output "  $TemplateDir/scripts/init-codex-project.sh /path/to/project"
