param()
$ErrorActionPreference = 'Stop'
$solveItRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$solveItVersion = '0.40.13'
$solveItHash = '7afa38624fa62ee5d8293422d0ab084c1bb4603134c7f4dafce11a033b57cc19'
$solveItLocal = Join-Path $solveItRoot '.local'
$solveItDownloads = Join-Path $solveItLocal 'downloads'
$solveItRuntime = Join-Path $solveItLocal "ollama/$solveItVersion"
$solveItArchive = Join-Path $solveItDownloads "ollama-windows-amd64-$solveItVersion.zip"
$solveItExecutable = Join-Path $solveItRuntime 'ollama.exe'
New-Item -ItemType Directory -Path $solveItDownloads -Force | Out-Null
New-Item -ItemType Directory -Path $solveItRuntime -Force | Out-Null
if ((Test-Path -LiteralPath $solveItExecutable) -and (Test-Path -LiteralPath (Join-Path $solveItRuntime 'solveit-runtime.json'))) {
    Write-Output "Portable runtime already present: $solveItExecutable"
    exit 0
}
Write-Output "Downloading official Ollama $solveItVersion into the project cache."
& curl.exe --fail --location --retry 3 --continue-at - --silent --show-error --output $solveItArchive "https://github.com/ollama/ollama/releases/download/v$solveItVersion/ollama-windows-amd64.zip"
if ($LASTEXITCODE -ne 0) { throw 'Runtime download failed; the partial archive is kept for resume.' }
if ((Get-FileHash -LiteralPath $solveItArchive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $solveItHash) {
    throw 'Runtime checksum mismatch. The archive will not be executed or extracted.'
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$solveItZip = [System.IO.Compression.ZipFile]::OpenRead($solveItArchive)
try {
    $solveItAllowedRoot = [System.IO.Path]::GetFullPath($solveItRuntime) + [System.IO.Path]::DirectorySeparatorChar
    foreach ($solveItEntry in $solveItZip.Entries) {
        $solveItTarget = [System.IO.Path]::GetFullPath((Join-Path $solveItRuntime $solveItEntry.FullName))
        if (-not $solveItTarget.StartsWith($solveItAllowedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw 'Unsafe archive entry; extraction refused.'
        }
    }
} finally { $solveItZip.Dispose() }
Expand-Archive -LiteralPath $solveItArchive -DestinationPath $solveItRuntime -Force
if (-not (Test-Path -LiteralPath $solveItExecutable)) { throw 'Expected Ollama executable missing from the release archive.' }
[pscustomobject]@{Version=$solveItVersion; SHA256=$solveItHash; Executable=$solveItExecutable} |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $solveItRuntime 'solveit-runtime.json') -Encoding utf8
Write-Output "Verified portable runtime ready: $solveItExecutable"
