param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path -LiteralPath $ProjectPath).Path
$RegistryRoot = Join-Path $Root "registry\neuraldeep"
$FixturesPath = Join-Path $Root "evals\srednoff-os-neuraldeep-registry-fixtures.json"
$PolicyPath = Join-Path $Root "policies\neuraldeep.yml"

foreach ($Path in @($RegistryRoot, $FixturesPath, $PolicyPath)) {
    if (-not (Test-Path -LiteralPath $Path)) { throw "Missing NeuralDeep registry dependency: $Path" }
}

$RequiredFiles = @("index.json", "skills.json", "mcp.json", "cli.json", "trust-report.json", "import-log.json", "README.md")
foreach ($File in $RequiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $RegistryRoot $File) -PathType Leaf)) {
        throw "Missing NeuralDeep registry file: $File"
    }
}

$BlockedPatterns = @(
    'sk-[A-Za-z0-9_-]{16,}',
    'gh[pousr]_[A-Za-z0-9_]{20,}',
    '-----BEGIN [A-Z ]+PRIVATE KEY-----'
)

$JsonFiles = @(Get-ChildItem -LiteralPath $RegistryRoot -Filter *.json -File)
foreach ($JsonFile in $JsonFiles) {
    $Text = Get-Content -LiteralPath $JsonFile.FullName -Raw -Encoding UTF8
    $Text | ConvertFrom-Json | Out-Null
    foreach ($Pattern in $BlockedPatterns) {
        if ($Text -match $Pattern) { throw "Blocked secret-like pattern in $($JsonFile.FullName)" }
    }
}

$Fixtures = Get-Content -LiteralPath $FixturesPath -Raw -Encoding UTF8 | ConvertFrom-Json
$Passed = 0
foreach ($Fixture in $Fixtures) {
    $Data = Get-Content -LiteralPath (Join-Path $RegistryRoot ([string]$Fixture.file)) -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($Fixture.PSObject.Properties.Name -contains "expectedEnabled") {
        if ([bool]$Data.enabled -ne [bool]$Fixture.expectedEnabled) { throw "Fixture $($Fixture.id) failed enabled" }
    }
    if ($Fixture.PSObject.Properties.Name -contains "expectedAutoInstall") {
        if ([bool]$Data.auto_install -ne [bool]$Fixture.expectedAutoInstall) { throw "Fixture $($Fixture.id) failed auto_install" }
    }
    if ($Fixture.PSObject.Properties.Name -contains "expectedAutoInstallAllowed") {
        if ([bool]$Data.auto_install_allowed -ne [bool]$Fixture.expectedAutoInstallAllowed) { throw "Fixture $($Fixture.id) failed auto_install_allowed" }
    }
    if ($Fixture.PSObject.Properties.Name -contains "expectedTrustedForExecution") {
        if ([bool]$Data.trusted_for_execution -ne [bool]$Fixture.expectedTrustedForExecution) { throw "Fixture $($Fixture.id) failed trusted_for_execution" }
    }
    $Passed++
}

foreach ($Catalog in @("skills.json", "mcp.json", "cli.json")) {
    $CatalogData = Get-Content -LiteralPath (Join-Path $RegistryRoot $Catalog) -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($Item in @($CatalogData.items)) {
        if ([bool]$Item.enabled) { throw "$Catalog item enabled unexpectedly: $($Item.id)" }
        if ([bool]$Item.auto_install) { throw "$Catalog item auto_install unexpectedly: $($Item.id)" }
        foreach ($RequiredField in @("source_url", "license", "provenance", "policy_gates", "risk_level")) {
            if (-not ($Item.PSObject.Properties.Name -contains $RequiredField) -or -not $Item.$RequiredField) {
                throw "$Catalog item $($Item.id) missing $RequiredField"
            }
        }
    }
}

Write-Output "Srednoff OS NeuralDeep registry evals passed: $Passed/$($Fixtures.Count)"
