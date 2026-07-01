param(
    [string]$ProjectPath = ".",
    [string]$Brief = "",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$DomainRouter = Join-Path $CodexHome "scripts\srednoff-os-domain-router.ps1"
$Lower = $Brief.ToLowerInvariant()

if (Test-Path -LiteralPath $DomainRouter -PathType Leaf) {
    $Domain = & $DomainRouter -ProjectPath $ProjectPath -Brief $Brief -Json | ConvertFrom-Json
} else {
    $Domain = [pscustomobject]@{ domains = @("ui-ux"); mode = "normal"; turbo = $false }
}

function Has-Term {
    param([string[]]$Terms)
    foreach ($Term in $Terms) {
        if ($Lower.Contains($Term)) { return $true }
    }
    return $false
}

$Questions = New-Object System.Collections.Generic.List[string]
$Assumptions = New-Object System.Collections.Generic.List[string]
$Domains = @($Domain.domains)

if ($Domains -contains "ui-ux" -or $Domains -contains "web-design") {
    if (-not (Has-Term @("user","audience","target","customer","buyer"))) {
        $Questions.Add("Who is the target user and what decision should the screen/page help them make?") | Out-Null
    }
    if (-not (Has-Term @("premium","minimal","editorial","saas","ecommerce","luxury","playful","utilitarian","brutalist"))) {
        $Questions.Add("What visual direction should guide the UI: premium SaaS, editorial, ecommerce, utilitarian, luxury, playful, or another style?") | Out-Null
        $Assumptions.Add("If no style is specified, use project conventions and a restrained, production-ready visual system.") | Out-Null
    }
    if (-not (Has-Term @("figma","canva","21st","shadcn","magic ui","aceternity","origin ui","react bits","local design system"))) {
        $Questions.Add("Should I use local components only, or also offer 21st.dev/Magic, Figma, Canva, shadcn, Magic UI, Aceternity, Origin UI, or React Bits?") | Out-Null
    }
}

if ($Domains -contains "3d-web") {
    if (-not (Has-Term @("viewer","configurator","hero","ar","xr","data viz","game","decorative"))) {
        $Questions.Add("Is the 3D work a product viewer, configurator, hero scene, AR preview, data visualization, game-like UI, or decorative scene?") | Out-Null
    }
    if (-not (Has-Term @("gltf","glb","model","asset","texture","hdri","provided"))) {
        $Questions.Add("Are 3D assets already provided, or should I rank safe sources and generate an asset acquisition/optimization plan?") | Out-Null
    }
    if (-not (Has-Term @("mobile","performance","fps","fallback","low power","reduced motion"))) {
        $Questions.Add("What is the mobile/performance target and required fallback for low-power or reduced-motion users?") | Out-Null
    }
    $Assumptions.Add("If no 3D stack is specified, choose the simplest stack that proves the product goal: model-viewer before custom Three.js/R3F.") | Out-Null
}

if ($Questions.Count -eq 0) {
    $Assumptions.Add("The provided brief is sufficient for first-pass implementation; continue with source ranking and validation gates.") | Out-Null
}

$Result = [ordered]@{
    name = "Srednoff OS design brief generator"
    version = "v2.1.2"
    project = if (Test-Path -LiteralPath $ProjectPath) { (Resolve-Path -LiteralPath $ProjectPath).Path } else { $ProjectPath }
    mode = $Domain.mode
    domains = @($Domains)
    should_ask_user = ($Questions.Count -gt 0)
    questions = @($Questions.ToArray() | Select-Object -First 5)
    assumptions = @($Assumptions.ToArray() | Select-Object -Unique)
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 6
} else {
    Write-Output "Srednoff OS design brief: ask_user=$($Result.should_ask_user) | domains=$($Domains -join ', ')"
    foreach ($Question in $Result.questions) {
        Write-Output "- $Question"
    }
    foreach ($Assumption in $Result.assumptions) {
        Write-Output "Assumption: $Assumption"
    }
}
