param(
    [ValidatePattern('^[a-zA-Z0-9._/-]+:[a-zA-Z0-9._-]+$')]
    [string]$Model = '',
    [switch]$RuntimeOnly,
    [switch]$Experimental
)
$ErrorActionPreference = 'Stop'
if ($Model -match 'cloud') { throw 'Cloud model tags are not supported.' }
if (-not $RuntimeOnly -and (-not $Model -or -not $Experimental)) {
    throw 'No model is approved for learner feedback. Use -RuntimeOnly for evaluation, or specify -Model and -Experimental for a development experiment. See docs/LOCAL_AI_VALIDATION.md.'
}
$solveItRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$solveItLocal = Join-Path $solveItRoot '.local'
$solveItRuntime = [System.IO.Path]::GetFullPath((Join-Path $solveItLocal 'ollama/0.40.13/ollama.exe'))
$solveItModels = Join-Path $solveItLocal 'models'
$solveItLogs = Join-Path $solveItLocal 'logs'
$solveItRuntimeRecord = Join-Path $solveItLocal 'runtime-process.json'
$solveItGatewayRecord = Join-Path $solveItLocal 'gateway-process.json'
if (-not (Test-Path -LiteralPath $solveItRuntime)) { throw 'Run scripts/setup-local-ai.ps1 first.' }
New-Item -ItemType Directory -Path $solveItModels,$solveItLogs -Force | Out-Null
$env:OLLAMA_HOST = '127.0.0.1:11434'
$env:OLLAMA_MODELS = $solveItModels
$env:OLLAMA_NO_CLOUD = '1'
$env:OLLAMA_NUM_PARALLEL = '1'
$env:OLLAMA_MAX_LOADED_MODELS = '1'
$env:OLLAMA_KEEP_ALIVE = '60s'
$env:OLLAMA_CONTEXT_LENGTH = '4096'

function Get-SolveItRuntime {
    try { Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/version' -TimeoutSec 2 } catch { $null }
}

$solveItVersion = Get-SolveItRuntime
if ($null -eq $solveItVersion) {
    $solveItProcess = Start-Process -FilePath $solveItRuntime -ArgumentList 'serve' -WindowStyle Hidden -PassThru -WorkingDirectory $solveItRoot -RedirectStandardOutput (Join-Path $solveItLogs 'runtime.out.log') -RedirectStandardError (Join-Path $solveItLogs 'runtime.err.log')
    [pscustomobject]@{Id=$solveItProcess.Id;Executable=$solveItRuntime;Created=$solveItProcess.StartTime.ToString('o')} | ConvertTo-Json | Set-Content -LiteralPath $solveItRuntimeRecord -Encoding utf8
    for ($solveItAttempt = 0; $solveItAttempt -lt 40 -and $null -eq $solveItVersion; $solveItAttempt++) {
        Start-Sleep -Milliseconds 250
        $solveItVersion = Get-SolveItRuntime
    }
    if ($null -eq $solveItVersion) { throw 'Local runtime did not start. Check .local/logs/runtime.err.log.' }
} else {
    if (-not (Test-Path -LiteralPath $solveItRuntimeRecord)) { throw 'An existing runtime owns port 11434. This script will not change its configuration.' }
    $solveItOwned = Get-Content -Raw -LiteralPath $solveItRuntimeRecord | ConvertFrom-Json
    $solveItExisting = Get-Process -Id $solveItOwned.Id -ErrorAction SilentlyContinue
    if ($null -eq $solveItExisting -or $solveItExisting.Path -ne $solveItRuntime -or $solveItExisting.StartTime.ToUniversalTime().Ticks -ne ([datetime]$solveItOwned.Created).ToUniversalTime().Ticks) { throw 'Runtime ownership could not be verified.' }
}
Write-Output "Local-only Ollama $($solveItVersion.version) is ready on 127.0.0.1:11434."
if ($RuntimeOnly) { exit 0 }
$solveItTags = Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/tags' -TimeoutSec 5
$solveItSelected = @($solveItTags.models | Where-Object { $_.name -eq $Model -and -not $_.remote_host -and -not $_.remote_model })
if ($solveItSelected.Count -ne 1) { throw "The local model '$Model' is not installed. Pull it explicitly with the portable Ollama executable, then rerun this script." }
try { $solveItHealth = Invoke-RestMethod -Uri 'http://127.0.0.1:8765/health' -TimeoutSec 2 } catch { $solveItHealth = $null }
if ($null -ne $solveItHealth) {
    if (-not (Test-Path -LiteralPath $solveItGatewayRecord)) { throw 'Port 8765 is already in use by another service.' }
    $solveItOwnedGateway = Get-Content -Raw -LiteralPath $solveItGatewayRecord | ConvertFrom-Json
    $solveItGatewayProcess = Get-Process -Id $solveItOwnedGateway.Id -ErrorAction SilentlyContinue
    if ($null -eq $solveItGatewayProcess -or $solveItGatewayProcess.Path -ne $solveItOwnedGateway.Executable -or $solveItOwnedGateway.Model -ne $Model -or $solveItGatewayProcess.StartTime.ToUniversalTime().Ticks -ne ([datetime]$solveItOwnedGateway.Created).ToUniversalTime().Ticks) { throw 'A different gateway owns port 8765. Stop that service before changing the model.' }
} else {
    $solveItPython = (Get-Command python -ErrorAction Stop).Source
    $solveItServer = Join-Path $solveItRoot 'services/local_coach/server.py'
    $solveItGateway = Start-Process -FilePath $solveItPython -ArgumentList @('-u', "`"$solveItServer`"", '--model', $Model) -WindowStyle Hidden -PassThru -WorkingDirectory $solveItRoot -RedirectStandardOutput (Join-Path $solveItLogs 'gateway.out.log') -RedirectStandardError (Join-Path $solveItLogs 'gateway.err.log')
    [pscustomobject]@{Id=$solveItGateway.Id;Model=$Model;Executable=$solveItPython;Created=$solveItGateway.StartTime.ToString('o')} | ConvertTo-Json | Set-Content -LiteralPath $solveItGatewayRecord -Encoding utf8
    for ($solveItAttempt = 0; $solveItAttempt -lt 40 -and $null -eq $solveItHealth; $solveItAttempt++) {
        Start-Sleep -Milliseconds 250
        try { $solveItHealth = Invoke-RestMethod -Uri 'http://127.0.0.1:8765/health' -TimeoutSec 2 } catch { }
    }
    if ($null -eq $solveItHealth) { throw 'Local coach did not start. Check .local/logs/gateway.err.log.' }
}
Write-Output "Experimental coach on 127.0.0.1:8765 using $Model. This model is not approved for learner feedback. Model weights stay on this computer."
