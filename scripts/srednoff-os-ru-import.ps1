param(
    [string]$ManifestPath = "",
    [string]$ProjectPath = ".",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path -LiteralPath $ProjectPath).Path
$ImporterPath = Join-Path $Root "integrations\neuraldeep\import-neuraldeep-registry.ps1"
$RegistryRoot = Join-Path $Root "registry\neuraldeep"

if (-not (Test-Path -LiteralPath $ImporterPath -PathType Leaf)) { throw "Missing importer: $ImporterPath" }
if (-not (Test-Path -LiteralPath $RegistryRoot -PathType Container)) { throw "Missing registry: $RegistryRoot" }

$ResolvedManifest = ""
if ($ManifestPath) {
    if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) { throw "Manifest not found: $ManifestPath" }
    $ResolvedManifest = (Resolve-Path -LiteralPath $ManifestPath).Path
}

$RecommendedCommand = if ($ResolvedManifest) {
    "powershell -ExecutionPolicy Bypass -File `"$ImporterPath`" -InputPath `"$ResolvedManifest`" -RegistryRoot `"$RegistryRoot`" -DryRun"
} else {
    "powershell -ExecutionPolicy Bypass -File `"$ImporterPath`" -InputPath `"<manifest.json>`" -RegistryRoot `"$RegistryRoot`" -DryRun"
}

$Result = [ordered]@{
    name = "Srednoff OS RU import wrapper"
    version = "v2.1.2"
    project = $Root
    mode = "recommendation-only"
    executed = $false
    manifest = $ResolvedManifest
    policy = "Run DryRun first. Do not import or enable external tools without provenance, license, permission, and human confirmation review."
    recommended_command = $RecommendedCommand
    next_checks = @(
        "test-srednoff-os-neuraldeep-importer.ps1",
        "test-srednoff-os-policies.ps1",
        "test-srednoff-os-agents.ps1"
    )
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 8
} else {
    Write-Output "Srednoff OS RU import wrapper: recommendation-only"
    Write-Output "executed: False"
    Write-Output "recommended command:"
    Write-Output "  $RecommendedCommand"
}

