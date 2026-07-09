param(
    [string]$ProjectPath = ".",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path -LiteralPath $ProjectPath).Path
$RequiredPaths = @(
    "policies\index.yml",
    "bundles\index.json",
    "agents\index.json",
    "registry\neuraldeep\index.json",
    "integrations\neuraldeep\import-neuraldeep-registry.ps1"
)

$Checks = New-Object System.Collections.Generic.List[object]
function Add-RuCheck {
    param([string]$Name, [string]$Status, [string]$Detail)
    $script:Checks.Add([pscustomobject]@{ name = $Name; status = $Status; detail = $Detail }) | Out-Null
}

foreach ($RelativePath in $RequiredPaths) {
    $Path = Join-Path $Root $RelativePath
    Add-RuCheck -Name $RelativePath -Status ($(if (Test-Path -LiteralPath $Path) { "OK" } else { "FAIL" })) -Detail $Path
}

$BundlesIndex = Join-Path $Root "bundles\index.json"
if (Test-Path -LiteralPath $BundlesIndex -PathType Leaf) {
    $Bundles = Get-Content -LiteralPath $BundlesIndex -Raw -Encoding UTF8 | ConvertFrom-Json
    Add-RuCheck -Name "bundles-disabled" -Status ($(if (-not [bool]$Bundles.default_enabled) { "OK" } else { "FAIL" })) -Detail "default_enabled=$($Bundles.default_enabled)"
}

$AgentsIndex = Join-Path $Root "agents\index.json"
if (Test-Path -LiteralPath $AgentsIndex -PathType Leaf) {
    $Agents = Get-Content -LiteralPath $AgentsIndex -Raw -Encoding UTF8 | ConvertFrom-Json
    Add-RuCheck -Name "agents-disabled" -Status ($(if (-not [bool]$Agents.default_enabled) { "OK" } else { "FAIL" })) -Detail "default_enabled=$($Agents.default_enabled)"
}

$RegistryIndex = Join-Path $Root "registry\neuraldeep\index.json"
if (Test-Path -LiteralPath $RegistryIndex -PathType Leaf) {
    $Registry = Get-Content -LiteralPath $RegistryIndex -Raw -Encoding UTF8 | ConvertFrom-Json
    $Safe = (-not [bool]$Registry.enabled) -and (-not [bool]$Registry.auto_install)
    Add-RuCheck -Name "neuraldeep-disabled" -Status ($(if ($Safe) { "OK" } else { "FAIL" })) -Detail "enabled=$($Registry.enabled); auto_install=$($Registry.auto_install)"
}

$Items = @($Checks.ToArray())
$FailCount = @($Items | Where-Object { $_.status -eq "FAIL" }).Count
$Result = [ordered]@{
    name = "Srednoff OS RU audit"
    version = "v2.1.2"
    project = $Root
    mode = "read-only"
    status = if ($FailCount -eq 0) { "OK" } else { "FAIL" }
    summary = [ordered]@{
        ok = @($Items | Where-Object { $_.status -eq "OK" }).Count
        fail = $FailCount
    }
    checks = @($Items)
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 8
} else {
    Write-Output "Srednoff OS RU audit: $($Result.status) | ok=$($Result.summary.ok) fail=$($Result.summary.fail)"
    $Items | Format-Table status, name, detail -AutoSize
}

if ($FailCount -gt 0) { exit 1 }

