param(
    [string]$Brief = "",
    [string]$PoliciesRoot = "",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRootPath = Resolve-Path -LiteralPath (Join-Path $ScriptDir "..") -ErrorAction SilentlyContinue
$PackageRoot = if ($PackageRootPath) { $PackageRootPath.Path } else { "" }
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }

function Resolve-PoliciesRoot {
    if ($PoliciesRoot) { return (Resolve-Path -LiteralPath $PoliciesRoot).Path }
    $Local = if ($PackageRoot) { Join-Path $PackageRoot "policies" } else { "" }
    if ($Local -and (Test-Path -LiteralPath $Local -PathType Container)) { return $Local }
    $HomePath = Join-Path $CodexHome "policies"
    if (Test-Path -LiteralPath $HomePath -PathType Container) { return $HomePath }
    throw "Policies directory not found"
}

function Read-PolicyScalar {
    param([string[]]$Lines, [string]$Name)
    $Pattern = "^\s*$([regex]::Escape($Name))\s*:\s*(.+?)\s*$"
    foreach ($Line in $Lines) {
        if ($Line -match $Pattern) { return $Matches[1].Trim().Trim('"').Trim("'") }
    }
    return ""
}

function Read-PolicyList {
    param([string[]]$Lines, [string]$Name)
    $Items = @()
    $InList = $false
    foreach ($Line in $Lines) {
        if ($Line -match "^\s*$([regex]::Escape($Name))\s*:\s*$") {
            $InList = $true
            continue
        }
        if ($InList) {
            if ($Line -match '^\s+-\s+(.+?)\s*$') {
                $Items += $Matches[1].Trim().Trim('"').Trim("'")
                continue
            }
            if ($Line -match '^\S') { break }
        }
    }
    return @($Items)
}

$Root = Resolve-PoliciesRoot
$PolicyFiles = @(Get-ChildItem -LiteralPath $Root -Filter *.yml -File | Where-Object { $_.Name -ne "index.yml" })
$Lower = $Brief.ToLowerInvariant()
$Matches = @()

foreach ($File in $PolicyFiles) {
    $Lines = Get-Content -LiteralPath $File.FullName -Encoding UTF8
    $Policy = [ordered]@{
        id = Read-PolicyScalar -Lines $Lines -Name "id"
        risk_level = Read-PolicyScalar -Lines $Lines -Name "risk_level"
        default_decision = Read-PolicyScalar -Lines $Lines -Name "default_decision"
        summary = Read-PolicyScalar -Lines $Lines -Name "summary"
        path = $File.FullName
        triggers = @(Read-PolicyList -Lines $Lines -Name "triggers")
        required_gates = @(Read-PolicyList -Lines $Lines -Name "required_gates")
        blocked_without_confirmation = @(Read-PolicyList -Lines $Lines -Name "blocked_without_confirmation")
    }
    $HitTriggers = @($Policy.triggers | Where-Object { $_ -and $Lower.Contains(([string]$_).ToLowerInvariant()) })
    if ($HitTriggers.Count -gt 0) {
        $Policy.hit_triggers = @($HitTriggers)
        $Matches += [pscustomobject]$Policy
    }
}

$Result = [ordered]@{
    name = "Srednoff OS policy check"
    version = "v2.1.2"
    root = $Root
    matched = @($Matches).Count
    policies = @($Matches)
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 8
} else {
    Write-Output "Srednoff OS policies matched: $($Result.matched)"
    $Matches | Format-Table id, risk_level, default_decision, hit_triggers -AutoSize
}
