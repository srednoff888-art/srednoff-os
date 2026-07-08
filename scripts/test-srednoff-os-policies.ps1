param(
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path -LiteralPath $ProjectPath).Path
$PoliciesRoot = Join-Path $Root "policies"
$PolicyScript = Join-Path $Root "scripts\srednoff-os-policy-check.ps1"
$FixturesPath = Join-Path $Root "evals\srednoff-os-policy-fixtures.json"

foreach ($Path in @($PoliciesRoot, $PolicyScript, $FixturesPath)) {
    if (-not (Test-Path -LiteralPath $Path)) { throw "Missing policy test dependency: $Path" }
}

$RequiredPolicies = @("ru-data", "ru-payments", "ru-messaging", "ru-marketplaces", "neuraldeep")
foreach ($PolicyId in $RequiredPolicies) {
    $Path = Join-Path $PoliciesRoot "$PolicyId.yml"
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Missing policy: $PolicyId" }
    $Text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    foreach ($RequiredField in @("schema:", "id:", "risk_level:", "default_decision:", "triggers:", "required_gates:", "blocked_without_confirmation:", "source_refs:")) {
        if ($Text -notmatch [regex]::Escape($RequiredField)) { throw "Policy $PolicyId missing $RequiredField" }
    }
    if ($Text -match 'legal_advice:\s*true') { throw "Policy $PolicyId must not claim legal advice" }
}

$Fixtures = Get-Content -LiteralPath $FixturesPath -Raw -Encoding UTF8 | ConvertFrom-Json
$Passed = 0
foreach ($Fixture in $Fixtures) {
    $Result = & $PolicyScript -Brief ([string]$Fixture.brief) -PoliciesRoot $PoliciesRoot -Json | ConvertFrom-Json
    $MatchedIds = @($Result.policies | ForEach-Object { $_.id })
    $Missing = @($Fixture.expectedPolicies | Where-Object { $MatchedIds -notcontains $_ })
    if ($Missing.Count -gt 0) {
        throw "Fixture $($Fixture.id) missing policies: $($Missing -join ',') actual=$($MatchedIds -join ',')"
    }
    $Passed++
}

Write-Output "Srednoff OS policy evals passed: $Passed/$($Fixtures.Count)"
