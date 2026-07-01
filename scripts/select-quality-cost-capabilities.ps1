param(
    [string]$ProjectPath = ".",
    [string]$Brief = "",
    [ValidateSet("lean", "balanced", "deep", "turbo")]
    [string]$Budget = "balanced",
    [int]$Max = 24,
    [string]$JsonOutput = "",
    [ValidateSet("compact", "ids")]
    [string]$Format = "compact"
)

$ErrorActionPreference = "Stop"

$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$Selector = Join-Path $CodexHome "skills\quality-cost-skill-kernel\scripts\select_core_capabilities.py"

if (-not (Test-Path -LiteralPath $Selector)) {
    throw "quality-cost selector not found: $Selector"
}

$Args = @($Selector, "--project", $ProjectPath, "--budget", $Budget, "--max", "$Max", "--format", $Format)
if ($Brief) {
    $Args += @("--brief", $Brief)
}
if ($JsonOutput) {
    $Args += @("--json-output", $JsonOutput)
}

python @Args
