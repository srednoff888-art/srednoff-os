param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path -LiteralPath $ProjectPath).Path
$RequiredScripts = @(
    "srednoff-os-ru-search.ps1",
    "srednoff-os-ru-audit.ps1",
    "srednoff-os-ru-import.ps1",
    "srednoff-os-ru-install.ps1"
)

foreach ($Script in $RequiredScripts) {
    $Path = Join-Path $Root "scripts\$Script"
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Missing RU CLI script: $Script" }
    $Text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    if ($Text -match 'Invoke-Expression|iex\s|Start-Process|npm\s+install|pip\s+install|powershell\s+-c|pwsh\s+-c') {
        throw "RU CLI script contains blocked execution/install pattern: $Script"
    }
}

$Search = & (Join-Path $Root "scripts\srednoff-os-ru-search.ps1") -ProjectPath $Root -Query "payments" -Json | ConvertFrom-Json
if ($Search.mode -ne "read-only") { throw "ru-search must be read-only" }
if ([int]$Search.count -lt 1) { throw "ru-search returned no matches" }

$Audit = & (Join-Path $Root "scripts\srednoff-os-ru-audit.ps1") -ProjectPath $Root -Json | ConvertFrom-Json
if ($Audit.status -ne "OK") { throw "ru-audit failed" }

$Import = & (Join-Path $Root "scripts\srednoff-os-ru-import.ps1") -ProjectPath $Root -ManifestPath (Join-Path $Root "evals\srednoff-os-neuraldeep-import-manifest.json") -Json | ConvertFrom-Json
if ([bool]$Import.executed) { throw "ru-import executed unexpectedly" }
if ($Import.mode -ne "recommendation-only") { throw "ru-import mode mismatch" }
if ($Import.recommended_command -notmatch '-DryRun') { throw "ru-import must recommend DryRun" }

$Install = & (Join-Path $Root "scripts\srednoff-os-ru-install.ps1") -ProjectPath $Root -CandidateId "find-skills" -Json | ConvertFrom-Json
if ([bool]$Install.executed) { throw "ru-install executed unexpectedly" }
if ($Install.mode -ne "blocked-without-confirmation") { throw "ru-install mode mismatch" }
if (@($Install.matches).Count -lt 1) { throw "ru-install did not find fixture candidate" }

Write-Output "Srednoff OS RU CLI evals passed: 4/4"

