param(
    [string[]]$ProjectPath = @("."),
    [string]$TemplateRoot = "$HOME\.codex\templates\codex-md-os",
    [switch]$IncludeScripts
)

$ErrorActionPreference = "Stop"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$TemplateRoot = if (Test-Path -LiteralPath $TemplateRoot -PathType Container) { (Resolve-Path -LiteralPath $TemplateRoot).Path } else { $TemplateRoot }
$SourceSkills = Join-Path $TemplateRoot ".codex\skills"
$SourceSrednoff = Join-Path $TemplateRoot ".codex\srednoff-os"
$SourceAgent = Join-Path $TemplateRoot ".agent"
$SourceScripts = Join-Path $TemplateRoot "scripts"
$SourceEvals = Join-Path $TemplateRoot "evals"
$SourceProfiles = Join-Path $TemplateRoot "profiles"
$SourcePolicies = Join-Path $TemplateRoot "policies"
$SourceRegistry = Join-Path $TemplateRoot "registry"
$SourceIntegrations = Join-Path $TemplateRoot "integrations"
$SourceBundles = Join-Path $TemplateRoot "bundles"
$SourceAgents = Join-Path $TemplateRoot "agents"
$SourceDocs = Join-Path $TemplateRoot "docs"

if (-not (Test-Path -LiteralPath $SourceSkills)) {
    throw "Template skills directory not found: $SourceSkills"
}

function Resolve-ProjectRoot {
    param([string]$Path)

    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    $Resolved = (Resolve-Path $Path).Path
    if (Test-Path -LiteralPath (Join-Path $Resolved "AGENTS.md") -PathType Leaf) {
        return $Resolved
    }

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
    foreach ($ExtraDirectory in @($SourceAgent, $SourceSrednoff, $SourceEvals, $SourceProfiles, $SourcePolicies, $SourceRegistry, $SourceIntegrations, $SourceBundles, $SourceAgents, $SourceDocs)) {
        if (Test-Path -LiteralPath $ExtraDirectory) {
            $Files += Get-ChildItem -LiteralPath $ExtraDirectory -Recurse -File
        }
    }
    if ($IncludeScripts -and (Test-Path -LiteralPath $SourceScripts)) {
        $Files += Get-ChildItem -LiteralPath $SourceScripts -Recurse -File
    }

    foreach ($File in $Files) {
        $Base = if ($File.FullName.StartsWith($SourceSkills, [System.StringComparison]::OrdinalIgnoreCase)) {
            $SourceSkills
        } elseif ($File.FullName.StartsWith($SourceAgent, [System.StringComparison]::OrdinalIgnoreCase)) {
            $SourceAgent
        } elseif ($File.FullName.StartsWith($SourceSrednoff, [System.StringComparison]::OrdinalIgnoreCase)) {
            $SourceSrednoff
        } elseif ($File.FullName.StartsWith($SourceEvals, [System.StringComparison]::OrdinalIgnoreCase)) {
            $SourceEvals
        } elseif ($File.FullName.StartsWith($SourceProfiles, [System.StringComparison]::OrdinalIgnoreCase)) {
            $SourceProfiles
        } elseif ($File.FullName.StartsWith($SourcePolicies, [System.StringComparison]::OrdinalIgnoreCase)) {
            $SourcePolicies
        } elseif ($File.FullName.StartsWith($SourceRegistry, [System.StringComparison]::OrdinalIgnoreCase)) {
            $SourceRegistry
        } elseif ($File.FullName.StartsWith($SourceIntegrations, [System.StringComparison]::OrdinalIgnoreCase)) {
            $SourceIntegrations
        } elseif ($File.FullName.StartsWith($SourceBundles, [System.StringComparison]::OrdinalIgnoreCase)) {
            $SourceBundles
        } elseif ($File.FullName.StartsWith($SourceAgents, [System.StringComparison]::OrdinalIgnoreCase)) {
            $SourceAgents
        } elseif ($File.FullName.StartsWith($SourceDocs, [System.StringComparison]::OrdinalIgnoreCase)) {
            $SourceDocs
        } else {
            $SourceScripts
        }
        $Relative = $File.FullName.Substring($Base.Length + 1)
        $DestinationPrefix = if ($Base -eq $SourceSkills) {
            ".codex\skills"
        } elseif ($Base -eq $SourceAgent) {
            ".agent"
        } elseif ($Base -eq $SourceSrednoff) {
            ".codex\srednoff-os"
        } elseif ($Base -eq $SourceEvals) {
            "evals"
        } elseif ($Base -eq $SourceProfiles) {
            "profiles"
        } elseif ($Base -eq $SourcePolicies) {
            "policies"
        } elseif ($Base -eq $SourceRegistry) {
            "registry"
        } elseif ($Base -eq $SourceIntegrations) {
            "integrations"
        } elseif ($Base -eq $SourceBundles) {
            "bundles"
        } elseif ($Base -eq $SourceAgents) {
            "agents"
        } elseif ($Base -eq $SourceDocs) {
            "docs"
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
        & $SkillIndexScript -SkillsRoot $ProjectSkillsRoot -OutputPath $ProjectSkillIndex -RelativePaths -RelativeBase $Root | Out-Host
    }
}

Write-Output ""
Write-Output "Summary:"
$Summary.GetEnumerator() | ForEach-Object { Write-Output "  $($_.Key): $($_.Value)" }
