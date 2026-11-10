param([switch]$Reveal)

$ErrorActionPreference = 'Stop'
if (-not $Reveal) {
  throw 'Run this script yourself with -Reveal in a private PowerShell window, then save the password in your password manager. Never paste it into chat or Git.'
}
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$credentialFile = Join-Path $projectRoot '.local/play-upload/credentials.dpapi'
if (-not (Test-Path -LiteralPath $credentialFile)) {
  throw 'The local Windows-encrypted upload credential was not found.'
}
$securePassword = ConvertTo-SecureString (Get-Content -LiteralPath $credentialFile -Raw)
$pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
try {
  $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
} finally {
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
}
Write-Output 'Keystore: .local/play-upload/looploom-upload.jks'
Write-Output 'Alias: looploom-upload'
Write-Output "Store and key password: $password"
$password = $null
