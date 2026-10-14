param (
    [switch] $icon,
    [switch] $code,
    [switch] $all
)

if ($all) {
    $icon = $true
    $code = $true
}

if ($icon) {
    dart run flutter_launcher_icons
}


function script:gen_about_infos {
    $lines = Get-Content "./pubspec.yaml"

    $desc = ""
    $version = ""

    $desc_prefix = "description:"
    $version_prefix = "version:"

    foreach ($line in $lines) {
        $line = $line.Trim()
        if ($line.Length -lt 1) {
            continue;
        }
        if ($line.StartsWith($desc_prefix)) {
            $desc = $line.Substring($desc_prefix.Length).Trim();
            continue;
        }
        if ($line.StartsWith($version_prefix)) {
            $version = $line.Substring($version_prefix.Length).Trim();
            break;
        }
    }

    $content = @"
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'about.page.dart';

final _version = "$version";
final _desc = r$desc;
"@
    Set-Content -Path "./lib/about.page.info.g.dart" -Value $content
}

if ($codes) {
    dart run build_runner build
    gen_about_infos
}