px gen -codes

$px_dir = $PSScriptRoot
$root = Split-Path -Parent $px_dir
$assets = Join-Path $root "assets"
$i18ns = Join-Path $assets "i18ns"

flutter run -d windows --dart-define=I18N_BASE_PATH=$i18ns
