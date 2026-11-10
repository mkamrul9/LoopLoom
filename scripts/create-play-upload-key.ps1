param(
  [string]$Keytool = 'keytool'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$privateDirectory = Join-Path $projectRoot '.local/play-upload'
$keystore = Join-Path $privateDirectory 'looploom-upload.jks'
$credentialFile = Join-Path $privateDirectory 'credentials.dpapi'
if ((Test-Path -LiteralPath $keystore) -or (Test-Path -LiteralPath $credentialFile)) {
  throw 'Play upload key material already exists. Refusing to overwrite it.'
}
New-Item -ItemType Directory -Path $privateDirectory -Force | Out-Null

$random = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$bytes = New-Object byte[] 36
try { $random.GetBytes($bytes) } finally { $random.Dispose() }
$password = [Convert]::ToBase64String($bytes)
$bytes = $null
$env:LOOPLOOM_UPLOAD_STORE_PASSWORD = $password
$env:LOOPLOOM_UPLOAD_KEY_PASSWORD = $password
try {
  & $Keytool -genkeypair -noprompt -alias 'looploom-upload' -keyalg RSA -keysize 4096 -validity 10000 -storetype PKCS12 -keystore $keystore -dname 'CN=LoopLoom Upload Key' -storepass:env LOOPLOOM_UPLOAD_STORE_PASSWORD -keypass:env LOOPLOOM_UPLOAD_KEY_PASSWORD 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $keystore)) {
    throw 'Keytool could not create the Play upload keystore.'
  }
  $encrypted = ConvertTo-SecureString -String $password -AsPlainText -Force | ConvertFrom-SecureString
  Set-Content -LiteralPath $credentialFile -Value $encrypted -NoNewline
} finally {
  Remove-Item Env:LOOPLOOM_UPLOAD_STORE_PASSWORD -ErrorAction SilentlyContinue
  Remove-Item Env:LOOPLOOM_UPLOAD_KEY_PASSWORD -ErrorAction SilentlyContinue
  $password = $null
}
Write-Output "Play upload key created in $privateDirectory. The password is Windows-user encrypted and never committed. Back up the keystore and recovery credentials securely before Play submission."
