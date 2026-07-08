param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path -LiteralPath $ProjectPath).Path
$ProfilesRoot = Join-Path $Root "profiles"
$ProfileScript = Join-Path $Root "scripts\srednoff-os-profile.ps1"
$FixturesPath = Join-Path $Root "evals\srednoff-os-profile-fixtures.json"

if (-not (Test-Path -LiteralPath $ProfilesRoot -PathType Container)) {
    throw "Missing profiles directory: $ProfilesRoot"
}
if (-not (Test-Path -LiteralPath $ProfileScript -PathType Leaf)) {
    throw "Missing profile script: $ProfileScript"
}
if (-not (Test-Path -LiteralPath $FixturesPath -PathType Leaf)) {
    throw "Missing profile fixtures: $FixturesPath"
}

$BlockedPatterns = @(
    'C:\\Users\\',
    '/Users/',
    'sk-[A-Za-z0-9_-]{16,}',
    'gh[pousr]_[A-Za-z0-9_]{20,}',
    '-----BEGIN [A-Z ]+PRIVATE KEY-----'
)

$JsonFiles = @(Get-ChildItem -LiteralPath $ProfilesRoot -Recurse -Filter *.json -File)
if ($JsonFiles.Count -lt 4) {
    throw "Expected at least 4 profile JSON files, got $($JsonFiles.Count)"
}

foreach ($JsonFile in $JsonFiles) {
    $Text = Get-Content -LiteralPath $JsonFile.FullName -Raw -Encoding UTF8
    $Text | ConvertFrom-Json | Out-Null
    foreach ($Pattern in $BlockedPatterns) {
        if ($Text -match $Pattern) {
            throw "Blocked private pattern in profile file: $($JsonFile.FullName)"
        }
    }
}

$List = & $ProfileScript -Action list -ProfilesRoot $ProfilesRoot -Json | ConvertFrom-Json
$Names = @($List.profiles | ForEach-Object { $_.name })
foreach ($ExpectedName in @("public-default", "ivan", "agency", "ru-market")) {
    if ($Names -notcontains $ExpectedName) {
        throw "Missing profile in index: $ExpectedName"
    }
}

$Fixtures = Get-Content -LiteralPath $FixturesPath -Raw -Encoding UTF8 | ConvertFrom-Json
$Passed = 0
foreach ($Fixture in $Fixtures) {
    $Resolved = & $ProfileScript -Action resolve -Profile $Fixture.profile -ProfilesRoot $ProfilesRoot -Json | ConvertFrom-Json
    if ([bool]$Resolved.resolved.default_enabled -ne [bool]$Fixture.expectedDefaultEnabled) {
        throw "Fixture $($Fixture.id) failed default_enabled"
    }
    if ($Fixture.PSObject.Properties.Name -contains "expectedPrivateOverlayAllowed") {
        if ([bool]$Resolved.resolved.private_overlay_allowed -ne [bool]$Fixture.expectedPrivateOverlayAllowed) {
            throw "Fixture $($Fixture.id) failed private_overlay_allowed"
        }
    }
    if ($Fixture.PSObject.Properties.Name -contains "expectedPolicyRequired") {
        if ([bool]$Resolved.resolved.policy_required -ne [bool]$Fixture.expectedPolicyRequired) {
            throw "Fixture $($Fixture.id) failed policy_required"
        }
    }
    $Passed++
}

Write-Output "Srednoff OS profile evals passed: $Passed/$($Fixtures.Count)"
