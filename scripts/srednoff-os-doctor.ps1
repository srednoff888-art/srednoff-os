param(
    [string]$ProjectPath = ".",
    [switch]$Json,
    [switch]$RunEvals,
    [switch]$FixSafe
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRootPath = Resolve-Path -LiteralPath (Join-Path $ScriptDir "..") -ErrorAction SilentlyContinue
$PackageRoot = if ($PackageRootPath) { $PackageRootPath.Path } else { "" }
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$ProjectRoot = if (Test-Path -LiteralPath $ProjectPath) { (Resolve-Path -LiteralPath $ProjectPath).Path } else { $ProjectPath }
$ExpectedKernelRecords = 4500
$ExpectedSkillRecords = 3300
$ExpectedAgentRecords = 1200

$Checks = New-Object System.Collections.Generic.List[object]

function Add-Check {
    param(
        [string]$Name,
        [ValidateSet("OK", "WARN", "FAIL")]
        [string]$Status,
        [string]$Detail,
        [string]$Fix = ""
    )
    $script:Checks.Add([pscustomobject]@{
        name = $Name
        status = $Status
        detail = $Detail
        fix = $Fix
    }) | Out-Null
}

function Count-JsonArray {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return 0 }
    $Data = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    return @($Data).Count
}

function Test-JsonFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    try {
        Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Resolve-LocalOrHome {
    param(
        [string]$LocalRelative,
        [string]$HomeRelative,
        [string]$PathType = "Any"
    )
    $Local = if ($PackageRoot) { Join-Path $PackageRoot $LocalRelative } else { "" }
    $HomePath = Join-Path $CodexHome $HomeRelative
    if ($Local) {
        if ($PathType -eq "Container" -and (Test-Path -LiteralPath $Local -PathType Container)) { return $Local }
        if ($PathType -eq "Leaf" -and (Test-Path -LiteralPath $Local -PathType Leaf)) { return $Local }
        if ($PathType -eq "Any" -and (Test-Path -LiteralPath $Local)) { return $Local }
    }
    return $HomePath
}

if ($FixSafe) {
    New-Item -ItemType Directory -Force -Path (Join-Path $CodexHome "srednoff-os\logs") | Out-Null
}

$StatusScript = Resolve-LocalOrHome "scripts\srednoff-os-status.ps1" "scripts\srednoff-os-status.ps1" "Leaf"
if (Test-Path -LiteralPath $StatusScript -PathType Leaf) {
    $StatusOutput = & $StatusScript -ProjectPath $ProjectRoot
    Add-Check -Name "status" -Status ($(if ($StatusOutput -match "loaded: OK") { "OK" } else { "WARN" })) -Detail $StatusOutput
} else {
    Add-Check -Name "status" -Status "FAIL" -Detail "Missing status script" -Fix "Restore scripts\srednoff-os-status.ps1"
}

$VersionFile = Resolve-LocalOrHome ".codex\srednoff-os\version.json" "srednoff-os\version.json" "Leaf"
if (Test-JsonFile -Path $VersionFile) {
    $VersionManifest = Get-Content -LiteralPath $VersionFile -Raw -Encoding UTF8 | ConvertFrom-Json
    $Version = $VersionManifest.version
    $Baseline = $VersionManifest.baseline
    $BaselineOk = (
        [int]$Baseline.kernel_records -eq $ExpectedKernelRecords -and
        [int]$Baseline.skill_records -eq $ExpectedSkillRecords -and
        [int]$Baseline.agent_records -eq $ExpectedAgentRecords
    )
    $VersionOk = $Version -eq "v2.1.2" -and $BaselineOk
    Add-Check -Name "version" -Status ($(if ($VersionOk) { "OK" } else { "WARN" })) -Detail "version=$Version; kernel_records=$($Baseline.kernel_records); skill_records=$($Baseline.skill_records); agent_records=$($Baseline.agent_records)"
} else {
    Add-Check -Name "version" -Status "FAIL" -Detail "Missing or invalid version manifest"
}

$ProfilesRoot = Resolve-LocalOrHome "profiles" "profiles" "Container"
$ProfilesIndex = Join-Path $ProfilesRoot "index.json"
if (Test-JsonFile -Path $ProfilesIndex) {
    $ProfilesManifest = Get-Content -LiteralPath $ProfilesIndex -Raw -Encoding UTF8 | ConvertFrom-Json
    $ProfileNames = @($ProfilesManifest.profiles | ForEach-Object { $_.name })
    $HasPublicDefault = $ProfileNames -contains "public-default"
    $HasIvanExample = $ProfileNames -contains "ivan"
    $HasAgency = $ProfileNames -contains "agency"
    $HasRuMarket = $ProfileNames -contains "ru-market"
    $ProfilesOk = $HasPublicDefault -and $HasIvanExample -and $HasAgency -and $HasRuMarket
    Add-Check -Name "profiles" -Status ($(if ($ProfilesOk) { "OK" } else { "WARN" })) -Detail "root=$ProfilesRoot; profiles=$($ProfileNames.Count); public-default=$HasPublicDefault; ivan=$HasIvanExample; agency=$HasAgency; ru-market=$HasRuMarket" -Fix "Restore profiles/index.json and profile JSON files"
} else {
    Add-Check -Name "profiles" -Status "FAIL" -Detail "Missing or invalid profiles/index.json" -Fix "Install or sync Srednoff OS profiles"
}

$QualityModes = Resolve-LocalOrHome ".codex\srednoff-os\quality-modes.json" "srednoff-os\quality-modes.json" "Leaf"
if (Test-JsonFile -Path $QualityModes) {
    $QualityManifest = Get-Content -LiteralPath $QualityModes -Raw -Encoding UTF8 | ConvertFrom-Json
    $QualityNames = @($QualityManifest.modes | ForEach-Object { $_.name })
    $QualityOk = ($QualityNames -contains "fast") -and ($QualityNames -contains "standard") -and ($QualityNames -contains "production") -and ($QualityNames -contains "critical")
    Add-Check -Name "quality-modes" -Status ($(if ($QualityOk) { "OK" } else { "FAIL" })) -Detail "modes=$($QualityNames -join ','); default=$($QualityManifest.default_quality_mode)" -Fix "Restore .codex\srednoff-os\quality-modes.json"
} else {
    Add-Check -Name "quality-modes" -Status "FAIL" -Detail "Missing or invalid quality-modes.json" -Fix "Install or sync Srednoff OS quality modes"
}

$PoliciesRoot = Resolve-LocalOrHome "policies" "policies" "Container"
$PoliciesIndex = Join-Path $PoliciesRoot "index.yml"
if (Test-Path -LiteralPath $PoliciesIndex -PathType Leaf) {
    $PolicyFiles = @(Get-ChildItem -LiteralPath $PoliciesRoot -Filter *.yml -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "index.yml" })
    $PolicyNames = @($PolicyFiles | ForEach-Object { $_.BaseName })
    $RequiredPolicyNames = @("ru-data", "ru-payments", "ru-messaging", "ru-marketplaces", "neuraldeep")
    $MissingPolicies = @($RequiredPolicyNames | Where-Object { $PolicyNames -notcontains $_ })
    Add-Check -Name "policies" -Status ($(if ($MissingPolicies.Count -eq 0) { "OK" } else { "FAIL" })) -Detail "root=$PoliciesRoot; policies=$($PolicyNames.Count); missing=$($MissingPolicies -join ',')" -Fix "Restore policies/*.yml"
} else {
    Add-Check -Name "policies" -Status "FAIL" -Detail "Missing policies/index.yml" -Fix "Install or sync Srednoff OS policies"
}

$NeuralDeepRegistry = Resolve-LocalOrHome "registry\neuraldeep" "registry\neuraldeep" "Container"
$NeuralDeepIndex = Join-Path $NeuralDeepRegistry "index.json"
if (Test-JsonFile -Path $NeuralDeepIndex) {
    $NeuralDeepManifest = Get-Content -LiteralPath $NeuralDeepIndex -Raw -Encoding UTF8 | ConvertFrom-Json
    $CatalogFiles = @("skills.json", "mcp.json", "cli.json", "trust-report.json", "import-log.json")
    $MissingCatalogFiles = @($CatalogFiles | Where-Object { -not (Test-Path -LiteralPath (Join-Path $NeuralDeepRegistry $_) -PathType Leaf) })
    $RegistrySafe = (-not [bool]$NeuralDeepManifest.enabled) -and (-not [bool]$NeuralDeepManifest.auto_install) -and ($MissingCatalogFiles.Count -eq 0)
    Add-Check -Name "neuraldeep-registry" -Status ($(if ($RegistrySafe) { "OK" } else { "FAIL" })) -Detail "root=$NeuralDeepRegistry; enabled=$($NeuralDeepManifest.enabled); auto_install=$($NeuralDeepManifest.auto_install); missing=$($MissingCatalogFiles -join ',')" -Fix "Restore disabled registry\neuraldeep skeleton"
} else {
    Add-Check -Name "neuraldeep-registry" -Status "FAIL" -Detail "Missing or invalid registry\neuraldeep\index.json" -Fix "Install or sync Srednoff OS NeuralDeep registry"
}

$Kernel = Resolve-LocalOrHome ".codex\skills\quality-cost-skill-kernel\references\core-3000-capabilities.json" "skills\quality-cost-skill-kernel\references\core-3000-capabilities.json" "Leaf"
$KernelCount = Count-JsonArray -Path $Kernel
Add-Check -Name "kernel" -Status ($(if ($KernelCount -eq $ExpectedKernelRecords) { "OK" } else { "FAIL" })) -Detail "records=$KernelCount expected=$ExpectedKernelRecords" -Fix "Run validate-quality-cost-kernel.ps1 -Rebuild"

$SkillIndex = Resolve-LocalOrHome ".codex\skill-index.json" "skill-index.json" "Leaf"
if (Test-JsonFile -Path $SkillIndex) {
    $Index = Get-Content -LiteralPath $SkillIndex -Raw -Encoding UTF8 | ConvertFrom-Json
    $Duplicates = @($Index | Group-Object name | Where-Object Count -gt 1)
    Add-Check -Name "skill-index" -Status ($(if ($Duplicates.Count -eq 0) { "OK" } else { "WARN" })) -Detail "entries=$(@($Index).Count); duplicate_names=$($Duplicates.Count)" -Fix "Rename duplicate SKILL.md frontmatter names, then regenerate skill-index"
    $SkillRoot = Resolve-LocalOrHome ".codex\skills" "skills" "Container"
    $SkillFiles = @(Get-ChildItem -LiteralPath $SkillRoot -Recurse -Filter SKILL.md -File -ErrorAction SilentlyContinue)
    $DirectNames = foreach ($SkillFile in $SkillFiles) {
        $Head = Get-Content -LiteralPath $SkillFile.FullName -Encoding UTF8 -TotalCount 12
        $NameLine = $Head | Where-Object { $_ -match '^\s*name\s*:' } | Select-Object -First 1
        if ($NameLine -match '^\s*name\s*:\s*["'']?([^"'']+)["'']?\s*$') { $Matches[1].Trim() }
    }
    $DirectDuplicates = @($DirectNames | Group-Object | Where-Object Count -gt 1)
    Add-Check -Name "skill-name-direct-scan" -Status ($(if ($DirectDuplicates.Count -eq 0) { "OK" } else { "WARN" })) -Detail "skill_files=$($SkillFiles.Count); duplicate_names=$($DirectDuplicates.Count)" -Fix "Rename duplicate SKILL.md frontmatter names"
} else {
    $SkillRoot = Resolve-LocalOrHome ".codex\skills" "skills" "Container"
    $SkillFiles = @(Get-ChildItem -LiteralPath $SkillRoot -Recurse -Filter SKILL.md -File -ErrorAction SilentlyContinue)
    Add-Check -Name "skill-index" -Status ($(if ($SkillFiles.Count -gt 0) { "OK" } else { "FAIL" })) -Detail "missing skill-index.json; direct_skill_files=$($SkillFiles.Count)" -Fix "Run generate-skill-index.ps1"
}

$HooksJson = Join-Path $CodexHome "hooks.json"
if (Test-JsonFile -Path $HooksJson) {
    $Hooks = Get-Content -LiteralPath $HooksJson -Raw -Encoding UTF8 | ConvertFrom-Json
    $HasSession = $Hooks.hooks.PSObject.Properties.Name -contains "SessionStart"
    $HasPrompt = $Hooks.hooks.PSObject.Properties.Name -contains "UserPromptSubmit"
    $HasPreTool = $Hooks.hooks.PSObject.Properties.Name -contains "PreToolUse"
    Add-Check -Name "hooks" -Status ($(if ($HasSession -and $HasPrompt -and $HasPreTool) { "OK" } else { "WARN" })) -Detail "SessionStart=$HasSession; UserPromptSubmit=$HasPrompt; PreToolUse=$HasPreTool"
} else {
    Add-Check -Name "hooks" -Status "WARN" -Detail "Missing hooks.json" -Fix "Install Srednoff OS v2.1 hooks.json"
}

$HookScript = Resolve-LocalOrHome "scripts\srednoff-os-hook.ps1" "scripts\srednoff-os-hook.ps1" "Leaf"
Add-Check -Name "hook-runner" -Status ($(if (Test-Path -LiteralPath $HookScript -PathType Leaf) { "OK" } else { "FAIL" })) -Detail $HookScript

$Config = Join-Path $CodexHome "config.toml"
if (Test-Path -LiteralPath $Config -PathType Leaf) {
    $ConfigText = Get-Content -LiteralPath $Config -Raw -Encoding UTF8
    $HasMcp = $ConfigText -match "\[mcp_servers\."
    $HasTrusted = $ConfigText -match "trust_level\s*=\s*""trusted"""
    $HomeConfigPath = ((Resolve-Path -LiteralPath $HOME).Path.TrimEnd("\")).ToLowerInvariant()
    $HomeSectionPattern = "(?ms)^\[projects\.'$([regex]::Escape($HomeConfigPath))'\](?:(?!^\[).)*?trust_level\s*=\s*""trusted"""
    $HomeTrusted = $ConfigText -match $HomeSectionPattern
    $ConfigFixDetail = ""
    if ($HomeTrusted -and $FixSafe) {
        $Backup = "$Config.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -LiteralPath $Config -Destination $Backup -Force
        $UpdatedConfig = [regex]::Replace(
            $ConfigText,
            $HomeSectionPattern,
            {
                param($Match)
                $Match.Value -replace 'trust_level\s*=\s*"trusted"', 'trust_level = "untrusted"'
            },
            1
        )
        Set-Content -LiteralPath $Config -Value $UpdatedConfig -Encoding UTF8
        $ConfigText = $UpdatedConfig
        $HasTrusted = $ConfigText -match "trust_level\s*=\s*""trusted"""
        $HomeTrusted = $ConfigText -match $HomeSectionPattern
        $ConfigFixDetail = "; home_root_trust_fixed=True; backup=$Backup"
    }
    Add-Check -Name "codex-config" -Status ($(if ($HomeTrusted) { "WARN" } elseif ($HasMcp -and $HasTrusted) { "OK" } else { "WARN" })) -Detail "mcp=$HasMcp; trusted_projects=$HasTrusted; home_root_trusted=$HomeTrusted$ConfigFixDetail" -Fix "Narrow trusted project roots instead of trusting <user-home>"
} else {
    Add-Check -Name "codex-config" -Status "WARN" -Detail "No config.toml found"
}

$InventoryScript = Resolve-LocalOrHome "scripts\srednoff-os-mcp-inventory.ps1" "scripts\srednoff-os-mcp-inventory.ps1" "Leaf"
if (Test-Path -LiteralPath $InventoryScript -PathType Leaf) {
    if ($FixSafe) { & $InventoryScript | Out-Null }
    $Inventory = Join-Path $CodexHome "srednoff-os\mcp-inventory.json"
    $InventoryStatus = "WARN"
    $InventoryDetail = $Inventory
    if (Test-Path -LiteralPath $Inventory -PathType Leaf) {
        $InventoryData = Get-Content -LiteralPath $Inventory -Raw -Encoding UTF8 | ConvertFrom-Json
        $FalseEnvServers = @($InventoryData.items | Where-Object { $_.kind -eq "mcp_server" -and $_.name -match '\.env$' })
        $InventoryStatus = if ($FalseEnvServers.Count -eq 0) { "OK" } else { "WARN" }
        $InventoryDetail = "$Inventory; entries=$($InventoryData.summary.total); false_env_servers=$($FalseEnvServers.Count)"
    }
    Add-Check -Name "mcp-inventory" -Status $InventoryStatus -Detail $InventoryDetail -Fix "Run srednoff-os-mcp-inventory.ps1"
} else {
    Add-Check -Name "mcp-inventory" -Status "FAIL" -Detail "Missing inventory script"
}

$Watchlist = Resolve-LocalOrHome ".codex\srednoff-os\source-watchlist.json" "srednoff-os\source-watchlist.json" "Leaf"
Add-Check -Name "source-watchlist" -Status ($(if (Test-JsonFile -Path $Watchlist) { "OK" } else { "FAIL" })) -Detail $Watchlist

$DesignRegistry = Resolve-LocalOrHome ".codex\srednoff-os\design-source-registry.json" "srednoff-os\design-source-registry.json" "Leaf"
Add-Check -Name "design-source-registry" -Status ($(if (Test-JsonFile -Path $DesignRegistry) { "OK" } else { "FAIL" })) -Detail $DesignRegistry
$SourceRegistryValidator = Resolve-LocalOrHome "scripts\validate-source-registry.ps1" "scripts\validate-source-registry.ps1" "Leaf"
if ((Test-Path -LiteralPath $SourceRegistryValidator -PathType Leaf) -and (Test-Path -LiteralPath $DesignRegistry -PathType Leaf)) {
    $global:LASTEXITCODE = 0
    $RegistryValidationOutput = & $SourceRegistryValidator -RegistryPath $DesignRegistry 2>&1
    $RegistryValidationOk = $LASTEXITCODE -eq 0
    Add-Check -Name "source-registry-metadata" -Status ($(if ($RegistryValidationOk) { "OK" } else { "FAIL" })) -Detail (($RegistryValidationOutput | Out-String).Trim()) -Fix "Fill license, provenance, vetted, and copy_policy fields"
} else {
    Add-Check -Name "source-registry-metadata" -Status "FAIL" -Detail "Missing source registry validator"
}

$WorkflowDir = Join-Path $ProjectRoot ".github\workflows"
$WorkflowFiles = @()
if (Test-Path -LiteralPath $WorkflowDir -PathType Container) {
    $WorkflowFiles = @(Get-ChildItem -LiteralPath $WorkflowDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '\.ya?ml$' })
}
Add-Check -Name "github-actions-ci" -Status ($(if ($WorkflowFiles.Count -gt 0) { "OK" } else { "WARN" })) -Detail "workflow_files=$($WorkflowFiles.Count)" -Fix "Add .github/workflows/ci.yml"

$ModeRouter = Resolve-LocalOrHome "scripts\srednoff-os-mode-router.ps1" "scripts\srednoff-os-mode-router.ps1" "Leaf"
$DomainRouter = Resolve-LocalOrHome "scripts\srednoff-os-domain-router.ps1" "scripts\srednoff-os-domain-router.ps1" "Leaf"
$SourceRanker = Resolve-LocalOrHome "scripts\srednoff-os-source-ranker.ps1" "scripts\srednoff-os-source-ranker.ps1" "Leaf"
$DesignBrief = Resolve-LocalOrHome "scripts\srednoff-os-design-brief.ps1" "scripts\srednoff-os-design-brief.ps1" "Leaf"
Add-Check -Name "mode-router" -Status ($(if (Test-Path -LiteralPath $ModeRouter -PathType Leaf) { "OK" } else { "FAIL" })) -Detail $ModeRouter
Add-Check -Name "domain-router" -Status ($(if (Test-Path -LiteralPath $DomainRouter -PathType Leaf) { "OK" } else { "FAIL" })) -Detail $DomainRouter
Add-Check -Name "source-ranker" -Status ($(if (Test-Path -LiteralPath $SourceRanker -PathType Leaf) { "OK" } else { "FAIL" })) -Detail $SourceRanker
Add-Check -Name "design-brief" -Status ($(if (Test-Path -LiteralPath $DesignBrief -PathType Leaf) { "OK" } else { "FAIL" })) -Detail $DesignBrief

$Automation = Join-Path $CodexHome "automations\daily-deep-skills-and-agents-research\automation.toml"
if (Test-Path -LiteralPath $Automation -PathType Leaf) {
    $AutoText = Get-Content -LiteralPath $Automation -Raw -Encoding UTF8
    $AutoOk = $AutoText -match "Srednoff OS" -and $AutoText -match "srednoff-os-status"
    Add-Check -Name "daily-automation" -Status ($(if ($AutoOk) { "OK" } else { "WARN" })) -Detail "daily-deep-skills-and-agents-research configured=$AutoOk"
} else {
    Add-Check -Name "daily-automation" -Status "WARN" -Detail "Missing daily research automation"
}

$CodexDocsRoot = Join-Path $HOME "Documents\Codex"
if (Test-Path -LiteralPath $CodexDocsRoot) {
    $AgentFiles = Get-ChildItem -LiteralPath $CodexDocsRoot -Recurse -Filter AGENTS.md -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\.git\\|node_modules|plugins\\cache|\\.tmp\\|\\.bak\\." }
    $WarnCount = 0
    foreach ($File in $AgentFiles) {
        $Text = Get-Content -LiteralPath $File.FullName -Raw -Encoding UTF8
        if ($Text -notmatch "Srednoff OS Startup Notification Rule") { $WarnCount++ }
    }
    Add-Check -Name "old-sessions" -Status ($(if ($WarnCount -eq 0) { "OK" } else { "WARN" })) -Detail "agents_files=$(@($AgentFiles).Count); missing_srednoff=$WarnCount" -Fix "Run init-codex-project.ps1 for missing project roots"
}

$StaleCore1000 = @(Get-ChildItem -LiteralPath $ProjectRoot -Recurse -File -Filter "*core-1000*" -ErrorAction SilentlyContinue).Count
$PyCache = @(Get-ChildItem -LiteralPath $ProjectRoot -Recurse -Directory -Filter "__pycache__" -ErrorAction SilentlyContinue).Count
Add-Check -Name "stale-artifacts" -Status ($(if ($StaleCore1000 -eq 0 -and $PyCache -eq 0) { "OK" } else { "WARN" })) -Detail "core-1000=$StaleCore1000; pycache=$PyCache" -Fix "Use safe cleanup dry-run before removal"

$NpmCmd = Get-Command npm.cmd -ErrorAction SilentlyContinue
$NpmPs1 = Get-Command npm.ps1 -ErrorAction SilentlyContinue
Add-Check -Name "node-tooling" -Status ($(if ($NpmCmd) { "OK" } else { "WARN" })) -Detail "npm.cmd=$([bool]$NpmCmd); npm.ps1=$([bool]$NpmPs1)"

if ($RunEvals) {
    $EvalScript = Resolve-LocalOrHome "scripts\test-srednoff-os-selector.ps1" "scripts\test-srednoff-os-selector.ps1" "Leaf"
    if (Test-Path -LiteralPath $EvalScript -PathType Leaf) {
        $global:LASTEXITCODE = 0
        $EvalOutput = & $EvalScript -ProjectPath $ProjectRoot 2>&1
        $EvalOk = $LASTEXITCODE -eq 0
        Add-Check -Name "selector-evals" -Status ($(if ($EvalOk) { "OK" } else { "FAIL" })) -Detail (($EvalOutput | Out-String).Trim())
    } else {
        Add-Check -Name "selector-evals" -Status "FAIL" -Detail "Missing eval script"
    }

    $V211EvalScript = Resolve-LocalOrHome "scripts\test-srednoff-os-v211.ps1" "scripts\test-srednoff-os-v211.ps1" "Leaf"
    if (Test-Path -LiteralPath $V211EvalScript -PathType Leaf) {
        $global:LASTEXITCODE = 0
        $V211EvalOutput = & $V211EvalScript -ProjectPath $ProjectRoot 2>&1
        $V211EvalOk = $LASTEXITCODE -eq 0
        Add-Check -Name "v211-evals" -Status ($(if ($V211EvalOk) { "OK" } else { "FAIL" })) -Detail (($V211EvalOutput | Out-String).Trim())
    } else {
        Add-Check -Name "v211-evals" -Status "FAIL" -Detail "Missing v2.1.1 eval script"
    }

    $V212EvalScript = Resolve-LocalOrHome "scripts\test-srednoff-os-v212.ps1" "scripts\test-srednoff-os-v212.ps1" "Leaf"
    if (Test-Path -LiteralPath $V212EvalScript -PathType Leaf) {
        $global:LASTEXITCODE = 0
        $V212EvalOutput = & $V212EvalScript -ProjectPath $ProjectRoot 2>&1
        $V212EvalOk = $LASTEXITCODE -eq 0
        Add-Check -Name "v212-evals" -Status ($(if ($V212EvalOk) { "OK" } else { "FAIL" })) -Detail (($V212EvalOutput | Out-String).Trim())
    } else {
        Add-Check -Name "v212-evals" -Status "FAIL" -Detail "Missing v2.1.2 eval script"
    }

    $SecurityFixtureScript = Resolve-LocalOrHome "scripts\test-srednoff-os-security-fixtures.ps1" "scripts\test-srednoff-os-security-fixtures.ps1" "Leaf"
    if (Test-Path -LiteralPath $SecurityFixtureScript -PathType Leaf) {
        $global:LASTEXITCODE = 0
        $SecurityFixtureOutput = & $SecurityFixtureScript -ProjectPath $ProjectRoot 2>&1
        $SecurityFixtureOk = $LASTEXITCODE -eq 0
        Add-Check -Name "security-fixture-evals" -Status ($(if ($SecurityFixtureOk) { "OK" } else { "FAIL" })) -Detail (($SecurityFixtureOutput | Out-String).Trim())
    } else {
        Add-Check -Name "security-fixture-evals" -Status "FAIL" -Detail "Missing security fixture eval script"
    }

    $ProfileEvalScript = Resolve-LocalOrHome "scripts\test-srednoff-os-profiles.ps1" "scripts\test-srednoff-os-profiles.ps1" "Leaf"
    if (Test-Path -LiteralPath $ProfileEvalScript -PathType Leaf) {
        $global:LASTEXITCODE = 0
        $ProfileEvalOutput = & $ProfileEvalScript -ProjectPath $ProjectRoot 2>&1
        $ProfileEvalOk = $LASTEXITCODE -eq 0
        Add-Check -Name "profile-evals" -Status ($(if ($ProfileEvalOk) { "OK" } else { "FAIL" })) -Detail (($ProfileEvalOutput | Out-String).Trim())
    } else {
        Add-Check -Name "profile-evals" -Status "FAIL" -Detail "Missing profile eval script"
    }

    $QualityModeEvalScript = Resolve-LocalOrHome "scripts\test-srednoff-os-quality-modes.ps1" "scripts\test-srednoff-os-quality-modes.ps1" "Leaf"
    if (Test-Path -LiteralPath $QualityModeEvalScript -PathType Leaf) {
        $global:LASTEXITCODE = 0
        $QualityModeEvalOutput = & $QualityModeEvalScript -ProjectPath $ProjectRoot 2>&1
        $QualityModeEvalOk = $LASTEXITCODE -eq 0
        Add-Check -Name "quality-mode-evals" -Status ($(if ($QualityModeEvalOk) { "OK" } else { "FAIL" })) -Detail (($QualityModeEvalOutput | Out-String).Trim())
    } else {
        Add-Check -Name "quality-mode-evals" -Status "FAIL" -Detail "Missing quality mode eval script"
    }

    $PolicyEvalScript = Resolve-LocalOrHome "scripts\test-srednoff-os-policies.ps1" "scripts\test-srednoff-os-policies.ps1" "Leaf"
    if (Test-Path -LiteralPath $PolicyEvalScript -PathType Leaf) {
        $global:LASTEXITCODE = 0
        $PolicyEvalOutput = & $PolicyEvalScript -ProjectPath $ProjectRoot 2>&1
        $PolicyEvalOk = $LASTEXITCODE -eq 0
        Add-Check -Name "policy-evals" -Status ($(if ($PolicyEvalOk) { "OK" } else { "FAIL" })) -Detail (($PolicyEvalOutput | Out-String).Trim())
    } else {
        Add-Check -Name "policy-evals" -Status "FAIL" -Detail "Missing policy eval script"
    }

    $NeuralDeepEvalScript = Resolve-LocalOrHome "scripts\test-srednoff-os-neuraldeep-registry.ps1" "scripts\test-srednoff-os-neuraldeep-registry.ps1" "Leaf"
    if (Test-Path -LiteralPath $NeuralDeepEvalScript -PathType Leaf) {
        $global:LASTEXITCODE = 0
        $NeuralDeepEvalOutput = & $NeuralDeepEvalScript -ProjectPath $ProjectRoot 2>&1
        $NeuralDeepEvalOk = $LASTEXITCODE -eq 0
        Add-Check -Name "neuraldeep-registry-evals" -Status ($(if ($NeuralDeepEvalOk) { "OK" } else { "FAIL" })) -Detail (($NeuralDeepEvalOutput | Out-String).Trim())
    } else {
        Add-Check -Name "neuraldeep-registry-evals" -Status "FAIL" -Detail "Missing NeuralDeep registry eval script"
    }
}

$CheckItems = @($Checks.ToArray())
$FailCount = @($CheckItems | Where-Object { $_.status -eq "FAIL" }).Count
$WarnCount = @($CheckItems | Where-Object { $_.status -eq "WARN" }).Count
$Overall = if ($FailCount -gt 0) { "FAIL" } elseif ($WarnCount -gt 0) { "WARN" } else { "OK" }

$Result = [ordered]@{
    name = "Srednoff OS doctor"
    version = "v2.1.2"
    status = $Overall
    project = $ProjectRoot
    generated_at = (Get-Date).ToUniversalTime().ToString("o")
    summary = [ordered]@{
        ok = @($CheckItems | Where-Object { $_.status -eq "OK" }).Count
        warn = $WarnCount
        fail = $FailCount
    }
    checks = @($CheckItems)
}

if ($Json) {
    $Result | ConvertTo-Json -Depth 8
} else {
    Write-Output "Srednoff OS v2.1.2 doctor: $Overall | ok=$($Result.summary.ok) warn=$WarnCount fail=$FailCount"
    $CheckItems | Format-Table status, name, detail -AutoSize
}

if ($FailCount -gt 0) { exit 1 }
