param(
    [string]$Brief = "",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$Text = $Brief.Trim()
$Lower = $Text.ToLowerInvariant()

$TurboPatterns = @(
    '(^|\s)turbo(\s|$)',
    'mode\s+turbo',
    'enable\s+turbo',
    'turbo\s+для'
)

$DeepPatterns = @(
    'максимальн',
    'без оглядки',
    'не экономь',
    'production',
    'security',
    'launch',
    'architecture',
    'seo',
    'ppc',
    'crypto',
    '3d',
    'mobile',
    'deploy',
    'migration',
    'audit'
)

$DeepLiteralPatterns = @(
    ([string]::Concat([char]0x043C,[char]0x0430,[char]0x043A,[char]0x0441,[char]0x0438,[char]0x043C,[char]0x0430,[char]0x043B,[char]0x044C,[char]0x043D)),
    ([string]::Concat([char]0x043D,[char]0x0435,[char]0x0020,[char]0x044D,[char]0x043A,[char]0x043E,[char]0x043D,[char]0x043E,[char]0x043C)),
    ([string]::Concat([char]0x0431,[char]0x0435,[char]0x0437,[char]0x0020,[char]0x043E,[char]0x0433,[char]0x043B,[char]0x044F,[char]0x0434))
)

$IsTurbo = $false
foreach ($Pattern in $TurboPatterns) {
    if ($Lower -match $Pattern) {
        $IsTurbo = $true
        break
    }
}

$IsDeep = $false
foreach ($Pattern in $DeepPatterns) {
    if ($Lower -match $Pattern) {
        $IsDeep = $true
        break
    }
}

if (-not $IsDeep) {
    foreach ($Pattern in $DeepLiteralPatterns) {
        if ($Lower.Contains($Pattern)) {
            $IsDeep = $true
            break
        }
    }
}

$Mode = if ($IsTurbo) { "turbo" } elseif ($IsDeep) { "deep" } else { "normal" }
$Budget = if ($Mode -eq "turbo") { "turbo" } elseif ($Mode -eq "deep") { "deep" } else { "balanced" }
$MaxCapabilities = if ($Mode -eq "turbo") { 48 } elseif ($Mode -eq "deep") { 24 } else { 16 }

$Result = [ordered]@{
    name = "Srednoff OS mode router"
    version = "v2.1.2"
    mode = $Mode
    budget = $Budget
    max_capabilities = $MaxCapabilities
    turbo = $IsTurbo
    reason = if ($IsTurbo) { "explicit TURBO trigger" } elseif ($IsDeep) { "high-value/deep-work trigger without TURBO" } else { "normal scoped work" }
    safety = [ordered]@{
        destructive_confirmation_required = $true
        paid_confirmation_required = $true
        production_confirmation_required = $true
        secret_protection_enabled = $true
        license_review_required = $true
    }
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 6
} else {
    Write-Output "Srednoff OS mode: $Mode | budget=$Budget | max=$MaxCapabilities | reason=$($Result.reason)"
}
