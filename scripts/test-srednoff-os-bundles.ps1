param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path -LiteralPath $ProjectPath).Path
$BundlesRoot = Join-Path $Root "bundles"
$IndexPath = Join-Path $BundlesRoot "index.json"
$SkillsRoot = Join-Path $Root ".codex\skills"
$PoliciesRoot = Join-Path $Root "policies"

foreach ($Path in @($BundlesRoot, $IndexPath, $SkillsRoot, $PoliciesRoot)) {
    if (-not (Test-Path -LiteralPath $Path)) { throw "Missing bundle test dependency: $Path" }
}

$Index = Get-Content -LiteralPath $IndexPath -Raw -Encoding UTF8 | ConvertFrom-Json
$RequiredBundles = @("ru-seo", "ru-marketplaces", "ru-enterprise", "ru-1c", "ru-llm", "ru-content", "ru-payments", "ru-messaging", "ru-devops")
$IndexBundles = @($Index.bundles)
$MissingBundles = @($RequiredBundles | Where-Object { $IndexBundles -notcontains $_ })
if ($MissingBundles.Count -gt 0) { throw "Missing bundles in index: $($MissingBundles -join ',')" }
if ([bool]$Index.default_enabled) { throw "Bundle index default_enabled must be false" }

$SkillNames = New-Object 'System.Collections.Generic.HashSet[string]'
Get-ChildItem -LiteralPath $SkillsRoot -Recurse -Filter SKILL.md -File | ForEach-Object {
    $Head = Get-Content -LiteralPath $_.FullName -Encoding UTF8 -TotalCount 12
    $NameLine = $Head | Where-Object { $_ -match '^\s*name\s*:' } | Select-Object -First 1
    if ($NameLine -match '^\s*name\s*:\s*["'']?([^"'']+)["'']?\s*$') {
        [void]$SkillNames.Add($Matches[1].Trim())
    }
}

$PolicyIds = @(Get-ChildItem -LiteralPath $PoliciesRoot -Filter *.yml -File | Where-Object { $_.BaseName -ne "index" } | ForEach-Object { $_.BaseName })
$Passed = 0
foreach ($BundleId in $RequiredBundles) {
    $BundlePath = Join-Path $BundlesRoot "$BundleId.json"
    if (-not (Test-Path -LiteralPath $BundlePath -PathType Leaf)) { throw "Missing bundle file: $BundleId" }
    $Bundle = Get-Content -LiteralPath $BundlePath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($Bundle.schema -ne "srednoff-os.bundle.v1") { throw "Bundle $BundleId schema mismatch" }
    if ($Bundle.id -ne $BundleId) { throw "Bundle $BundleId id mismatch" }
    if ([bool]$Bundle.default_enabled) { throw "Bundle $BundleId default_enabled must be false" }
    foreach ($Field in @("domains", "policy_gates", "recommended_skills", "selector_hints", "validation_gates", "blocked_without_confirmation")) {
        if (-not ($Bundle.PSObject.Properties.Name -contains $Field) -or @($Bundle.$Field).Count -eq 0) {
            throw "Bundle $BundleId missing $Field"
        }
    }
    $MissingPolicies = @($Bundle.policy_gates | Where-Object { $PolicyIds -notcontains $_ })
    if ($MissingPolicies.Count -gt 0) { throw "Bundle $BundleId references missing policies: $($MissingPolicies -join ',')" }
    $MissingSkills = @($Bundle.recommended_skills | Where-Object { -not $SkillNames.Contains([string]$_) })
    if ($MissingSkills.Count -gt 0) { throw "Bundle $BundleId references missing skills: $($MissingSkills -join ',')" }
    $Passed++
}

Write-Output "Srednoff OS bundle evals passed: $Passed/$($RequiredBundles.Count)"

