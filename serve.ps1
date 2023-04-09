$ProgressPreference = 'SilentlyContinue'
if (!(Test-Path -Path .\cobalt\cobalt.exe)) {
    Write-Output "Downloading cobalt"
    Invoke-WebRequest -UseBasicParsing -OutFile cobalt.zip https://github.com/cobalt-org/cobalt.rs/releases/download/v0.18.3/cobalt-v0.18.3-x86_64-pc-windows-msvc.zip
    $hash = Get-FileHash -Algorithm SHA256 .\cobalt.zip
    if ($hash.Hash -ne "01F658867B03459D218CAC88FF18A4DFD836745A222239568A8AE7BADEF9A5E3") {
        throw "failed to valdate hash"
    }
    if (-not (test-path cobalt)) {
        mkdir cobalt
    }
    Expand-Archive -Path .\cobalt.zip -DestinationPath cobalt
}
& .\cobalt\cobalt.exe serve -c input/_cobalt.yml -d _site $args
