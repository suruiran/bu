param (
    [switch] $apk,
    [switch] $win,
    [switch] $all
)

if ($all) {
    $apk = $true
    $win = $true
}

$ErrorActionPreference = 'Stop'

$extraArgs = @()

$symbolPath = Join-Path $PSScriptRoot "build\symbols"
if (-not (Test-Path $symbolPath)) {
    New-Item -ItemType Directory -Path $symbolPath -Force | Out-Null
}
$extraArgs += "--obfuscate"
$extraArgs += "--split-debug-info=$symbolPath"

if ($apk) {
    $apkArgs = @("build", "apk", "--release", "--split-per-abi") + $extraArgs
    flutter @apkArgs
}

if ($win) {
    $winArgs = @("build", "windows", "--release") + $extraArgs
    flutter @winArgs
}
