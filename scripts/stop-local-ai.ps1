param([switch]$Runtime)
$ErrorActionPreference = 'Stop'
$solveItRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$solveItLocal = Join-Path $solveItRoot '.local'
$solveItRuntimeRecord = Join-Path $solveItLocal 'runtime-process.json'
$solveItGatewayRecord = Join-Path $solveItLocal 'gateway-process.json'

function Get-SolveItOwnedProcess([string]$RecordPath) {
    if (-not (Test-Path -LiteralPath $RecordPath)) { return $null }
    $solveItRecord = Get-Content -LiteralPath $RecordPath -Raw | ConvertFrom-Json
    $solveItProcess = Get-Process -Id $solveItRecord.Id -ErrorAction SilentlyContinue
    if ($null -eq $solveItProcess) { return $null }
    if ($solveItProcess.Path -ne $solveItRecord.Executable -or $solveItProcess.StartTime.ToUniversalTime().Ticks -ne ([datetime]$solveItRecord.Created).ToUniversalTime().Ticks) {
        throw "Process ownership could not be verified for $RecordPath; no process was stopped."
    }
    return $solveItProcess
}

$solveItGateway = Get-SolveItOwnedProcess $solveItGatewayRecord
if ($null -ne $solveItGateway) {
    Stop-Process -Id $solveItGateway.Id
    Write-Output 'Stopped the LoopLoom development gateway.'
}
$solveItDaemon = Get-SolveItOwnedProcess $solveItRuntimeRecord
if ($null -ne $solveItDaemon) {
    if ($Runtime) {
        Stop-Process -Id $solveItDaemon.Id
        Write-Output 'Stopped the LoopLoom portable runtime.'
    } else {
        $solveItLoaded = Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/ps' -TimeoutSec 5
        foreach ($solveItModel in $solveItLoaded.models) {
            $solveItBody = @{model=$solveItModel.name;keep_alive=0;stream=$false} | ConvertTo-Json -Compress
            Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/generate' -Method Post -ContentType 'application/json' -Body $solveItBody -TimeoutSec 30 | Out-Null
        }
        Write-Output 'Unloaded model weights; the portable runtime remains available.'
    }
}
