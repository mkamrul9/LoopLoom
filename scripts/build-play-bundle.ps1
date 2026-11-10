param(
  [string]$Flutter = 'flutter'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$privateDirectory = Join-Path $projectRoot '.local/play-upload'
$keystore = Join-Path $privateDirectory 'looploom-upload.jks'
$credentialFile = Join-Path $privateDirectory 'credentials.dpapi'
if (-not (Test-Path -LiteralPath $keystore) -or -not (Test-Path -LiteralPath $credentialFile)) {
  throw 'Create the local upload key with scripts/create-play-upload-key.ps1 first.'
}
$securePassword = ConvertTo-SecureString (Get-Content -LiteralPath $credentialFile -Raw)
$pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
try {
  $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
} finally {
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
}
$env:LOOPLOOM_UPLOAD_KEYSTORE = $keystore
$env:LOOPLOOM_UPLOAD_STORE_PASSWORD = $password
$env:LOOPLOOM_UPLOAD_KEY_ALIAS = 'looploom-upload'
$env:LOOPLOOM_UPLOAD_KEY_PASSWORD = $password
$password = $null
$appDirectory = Join-Path $projectRoot 'apps/solveit'
$arguments = @('build', 'appbundle', '--release', '--no-pub')
if (Test-Path -LiteralPath (Join-Path $appDirectory 'firebase.ai.json')) {
  $arguments += '--dart-define-from-file=firebase.ai.json'
}
Push-Location $appDirectory
try {
  & $Flutter @arguments
  if ($LASTEXITCODE -ne 0) { throw 'Play App Bundle build failed.' }
} finally {
  Pop-Location
  Remove-Item Env:LOOPLOOM_UPLOAD_KEYSTORE -ErrorAction SilentlyContinue
  Remove-Item Env:LOOPLOOM_UPLOAD_STORE_PASSWORD -ErrorAction SilentlyContinue
  Remove-Item Env:LOOPLOOM_UPLOAD_KEY_ALIAS -ErrorAction SilentlyContinue
  Remove-Item Env:LOOPLOOM_UPLOAD_KEY_PASSWORD -ErrorAction SilentlyContinue
}
Write-Output "Play upload bundle ready: $(Join-Path $appDirectory 'build/app/outputs/bundle/release/app-release.aab')"
