param(
  [string]$Flutter = 'flutter'
)

$ErrorActionPreference = 'Stop'
$appDirectory = Join-Path $PSScriptRoot '..\apps\solveit'
$config = Join-Path $appDirectory 'firebase.ai.json'
$arguments = @('build', 'web', '--release', '--no-pub')
if (Test-Path -LiteralPath $config) {
  $arguments += '--dart-define-from-file=firebase.ai.json'
}

Push-Location $appDirectory
try {
  & $Flutter @arguments
  if ($LASTEXITCODE -ne 0) { throw 'Flutter web build failed.' }
} finally {
  Pop-Location
}

$worker = Join-Path $appDirectory 'build\web\looploom-sw.js'
$source = Get-Content -LiteralPath $worker -Raw
if (-not $source.Contains('__BUILD_ID__')) {
  throw 'The service worker build token is missing.'
}
$buildId = (Get-Date).ToUniversalTime().ToString('yyyyMMddHHmmssfff')
$source = $source.Replace('__BUILD_ID__', $buildId)
Set-Content -LiteralPath $worker -Value $source -NoNewline -Encoding utf8
Write-Host "Web release ready. Offline cache version: $buildId"
