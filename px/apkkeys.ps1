$keytool = $env:KEYTOOL
$keystore = $env:KEYSTORE

$alias = "bu"

$secure = Read-Host "Password" -AsSecureString
$pwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))

& $keytool -genkeypair -v -keystore $keystore -storetype PKCS12 `
    -alias $alias -keyalg RSA -keysize 2048 -validity 10000 `
    -storepass $pwd -keypass $pwd `
    -dname "CN=Bu, OU=Mobile, O=Bu, L=Shanghai, ST=Shanghai, C=CN"

@(
    "storeFile=upload-keystore.jks"
    "storePassword=$pwd"
    "keyAlias=$alias"
    "keyPassword=$pwd"
) | Set-Content android\key.properties

[Convert]::ToBase64String([IO.File]::ReadAllBytes($keystore)) | Set-Clipboard
