param([switch]$Development)
$ErrorActionPreference = 'Stop'
if (-not $Development) { throw 'Use -Development to start this local-only experimental reference runner.' }
$solveItRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$solveItLogs = Join-Path $solveItRoot '.local/logs'
New-Item -ItemType Directory -Path $solveItLogs -Force | Out-Null
try { $solveItExisting = Invoke-RestMethod -Uri 'http://127.0.0.1:8766/health' -TimeoutSec 2 } catch { $solveItExisting = $null }
if ($null -ne $solveItExisting) { throw 'A service already owns port 8766. This helper will not change it.' }
$solveItPython = (Get-Command python).Source
$solveItServer = Join-Path $solveItRoot 'services/reference_runner/server.py'
$solveItProcess = Start-Process -FilePath $solveItPython -ArgumentList @('-u', "`"$solveItServer`"", '--development') -WindowStyle Hidden -PassThru -WorkingDirectory $solveItRoot -RedirectStandardOutput (Join-Path $solveItLogs 'reference-runner.out.log') -RedirectStandardError (Join-Path $solveItLogs 'reference-runner.err.log')
[pscustomobject]@{Id=$solveItProcess.Id;Executable=$solveItPython;Created=$solveItProcess.StartTime.ToString('o')} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $solveItRoot '.local/reference-runner-process.json')
for ($solveItAttempt=0; $solveItAttempt -lt 20; $solveItAttempt++) {
    Start-Sleep -Milliseconds 500
    try {
        $solveItHealth = Invoke-RestMethod -Uri 'http://127.0.0.1:8766/health' -TimeoutSec 8
        if ($solveItHealth.ready) { Write-Output "Local development runner ready on 127.0.0.1:8766. Available languages: $($solveItHealth.languages -join ', ')."; exit 0 }
    } catch { }
    if ($solveItProcess.HasExited) { break }
}
throw 'Runner is not ready. Check .local/logs/reference-runner.err.log; stop it with scripts/stop-reference-runner.ps1.'
