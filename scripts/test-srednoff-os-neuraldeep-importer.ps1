param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path -LiteralPath $ProjectPath).Path
$Importer = Join-Path $Root "integrations\neuraldeep\import-neuraldeep-registry.ps1"
$Manifest = Join-Path $Root "evals\srednoff-os-neuraldeep-import-manifest.json"
$SourceRegistry = Join-Path $Root "registry\neuraldeep"

foreach ($Path in @($Importer, $Manifest, $SourceRegistry)) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Missing NeuralDeep importer dependency: $Path"
    }
}

$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "srednoff-os-neuraldeep-importer-$([guid]::NewGuid().ToString('N'))"
$TempRegistry = Join-Path $TempRoot "registry\neuraldeep"
$ReportPath = Join-Path $TempRoot "report.json"

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $TempRegistry) | Out-Null
Copy-Item -LiteralPath $SourceRegistry -Destination (Split-Path -Parent $TempRegistry) -Recurse -Force

$Output = & $Importer -InputPath $Manifest -RegistryRoot $TempRegistry -ReportPath $ReportPath
$Report = $Output | ConvertFrom-Json

if ([int]$Report.summary.imported -ne 1) { throw "Expected imported=1" }
if ([int]$Report.summary.rejected -ne 1) { throw "Expected rejected=1" }
if ([int]$Report.summary.duplicates -ne 1) { throw "Expected duplicates=1" }
if (-not (Test-Path -LiteralPath $ReportPath -PathType Leaf)) { throw "Missing import report" }

$Skills = Get-Content -LiteralPath (Join-Path $TempRegistry "skills.json") -Raw -Encoding UTF8 | ConvertFrom-Json
$ImportedSkill = @($Skills.items | Where-Object { $_.id -eq "safe-review-skill" }) | Select-Object -First 1
if (-not $ImportedSkill) { throw "Imported skill not found" }
if ([bool]$ImportedSkill.enabled) { throw "Imported skill enabled unexpectedly" }
if ([bool]$ImportedSkill.auto_install) { throw "Imported skill auto_install unexpectedly" }
if ($ImportedSkill.license -ne "MIT") { throw "Imported skill license mismatch" }
if ([int]$ImportedSkill.trust_score -lt 80) { throw "Imported skill trust score too low" }

$Mcp = Get-Content -LiteralPath (Join-Path $TempRegistry "mcp.json") -Raw -Encoding UTF8 | ConvertFrom-Json
$RejectedMcp = @($Mcp.items | Where-Object { $_.id -eq "unsafe-unknown-license" })
if ($RejectedMcp.Count -ne 0) { throw "Unknown-license MCP was imported unexpectedly" }

$Log = Get-Content -LiteralPath (Join-Path $TempRegistry "import-log.json") -Raw -Encoding UTF8 | ConvertFrom-Json
$ImportEvents = @($Log.events | Where-Object { $_.event -eq "controlled-import" })
if ($ImportEvents.Count -ne 1) { throw "Missing controlled-import log event" }

& $Importer -InputPath $Manifest -RegistryRoot $TempRegistry -DryRun | Out-Null
$SkillsAfterDryRun = Get-Content -LiteralPath (Join-Path $TempRegistry "skills.json") -Raw -Encoding UTF8 | ConvertFrom-Json
$ImportedCountAfterDryRun = @($SkillsAfterDryRun.items | Where-Object { $_.id -eq "safe-review-skill" }).Count
if ($ImportedCountAfterDryRun -ne 1) { throw "DryRun changed registry unexpectedly" }

Remove-Item -LiteralPath $TempRoot -Recurse -Force

Write-Output "Srednoff OS NeuralDeep importer evals passed: 5/5"
