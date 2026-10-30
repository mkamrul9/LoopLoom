$ErrorActionPreference = 'Stop'
$solveItRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$solveItRecordPath = Join-Path $solveItRoot '.local/reference-runner-process.json'
if (-not (Test-Path -LiteralPath $solveItRecordPath)) { exit 0 }
$solveItRecord = Get-Content -LiteralPath $solveItRecordPath -Raw | ConvertFrom-Json
$solveItProcess = Get-Process -Id $solveItRecord.Id -ErrorAction SilentlyContinue
if ($null -eq $solveItProcess) { exit 0 }
if ($solveItProcess.Path -ne $solveItRecord.Executable -or $solveItProcess.StartTime.ToUniversalTime().Ticks -ne ([datetime]$solveItRecord.Created).ToUniversalTime().Ticks) { throw 'Runner process ownership could not be verified.' }
# Per-case cleanup belongs to the runner: stop only when no request is active.
$solveItActive = & docker --context desktop-linux ps -aq --filter 'label=dev.solveit.reference=true'
if ($LASTEXITCODE -ne 0 -or $solveItActive) { throw 'Docker is unavailable or a runner container is active. Wait for the bounded request to finish before stopping.' }
Stop-Process -Id $solveItProcess.Id
Write-Output 'Stopped the project-owned reference runner.'
