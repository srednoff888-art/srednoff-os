param(
    [ValidateSet("list", "show", "resolve")]
    [string]$Action = "list",
    [string]$Profile = "public-default",
    [string]$ProfilesRoot = "",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRootPath = Resolve-Path -LiteralPath (Join-Path $ScriptDir "..") -ErrorAction SilentlyContinue
$PackageRoot = if ($PackageRootPath) { $PackageRootPath.Path } else { "" }
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }

function Resolve-ProfilesRoot {
    if ($ProfilesRoot) {
        return (Resolve-Path -LiteralPath $ProfilesRoot).Path
    }

    $LocalProfiles = if ($PackageRoot) { Join-Path $PackageRoot "profiles" } else { "" }
    if ($LocalProfiles -and (Test-Path -LiteralPath $LocalProfiles -PathType Container)) {
        return $LocalProfiles
    }

    $HomeProfiles = Join-Path $CodexHome "profiles"
    if (Test-Path -LiteralPath $HomeProfiles -PathType Container) {
        return $HomeProfiles
    }

    throw "Profiles directory not found"
}

function Read-JsonFile {
    param([Parameter(Mandatory=$true)][string]$Path)
    Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
}

$Root = Resolve-ProfilesRoot
$IndexPath = Join-Path $Root "index.json"
if (-not (Test-Path -LiteralPath $IndexPath -PathType Leaf)) {
    throw "Profile index not found: $IndexPath"
}

$Index = Read-JsonFile -Path $IndexPath
$Profiles = @($Index.profiles)

if ($Action -eq "list") {
    $Result = [ordered]@{
        schema = $Index.schema
        version = $Index.version
        default_profile = $Index.default_profile
        root = $Root
        profiles = $Profiles
    }
} else {
    $Entry = $Profiles | Where-Object { $_.name -eq $Profile } | Select-Object -First 1
    if (-not $Entry) {
        throw "Unknown profile: $Profile"
    }

    $ProfilePath = Join-Path $Root $Entry.path
    if (-not (Test-Path -LiteralPath $ProfilePath -PathType Leaf)) {
        throw "Profile file not found: $ProfilePath"
    }

    $ProfileData = Read-JsonFile -Path $ProfilePath
    $Result = [ordered]@{
        name = $Entry.name
        root = $Root
        path = $ProfilePath
        index = $Entry
        profile = $ProfileData
    }

    if ($Action -eq "resolve") {
        $Result.resolved = [ordered]@{
            active_profile = $ProfileData.name
            mode_default = $ProfileData.mode_default
            budget = $ProfileData.selector.budget
            max_capabilities = $ProfileData.selector.max_capabilities
            default_enabled = [bool]$ProfileData.default_enabled
            private_overlay_allowed = [bool]$ProfileData.private_overlay_allowed
            policy_required = [bool]$ProfileData.policy_required
        }
    }
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 8
} else {
    if ($Action -eq "list") {
        Write-Output "Srednoff OS profiles: root=$Root default=$($Index.default_profile)"
        $Profiles | Format-Table name, path, default_enabled, risk -AutoSize
    } else {
        Write-Output "Srednoff OS profile: $($Result.name)"
        Write-Output "path: $($Result.path)"
        Write-Output "default_enabled: $($Result.profile.default_enabled)"
        Write-Output "mode_default: $($Result.profile.mode_default)"
        Write-Output "budget: $($Result.profile.selector.budget)"
    }
}
