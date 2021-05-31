$ProgressPreference = 'SilentlyContinue'
if (!(Test-Path -Path .\cobalt.exe)) {
    Write-Output "Downloading cobalt"
    Invoke-WebRequest -UseBasicParsing -OutFile cobalt.zip https://github.com/cobalt-org/cobalt.rs/releases/download/v0.16.5/cobalt-v0.16.5-x86_64-pc-windows-msvc.zip
    $hash = Get-FileHash -Algorithm SHA256 .\cobalt.zip
    if ($hash.Hash -ne "3CEA67F4A2BBB62E42B12ABAC29AA5C5842804E481EAF30E63B65C52975953B7") {
        throw "failed to valdate hash"
    }
    Expand-Archive -Path .\cobalt.zip -DestinationPath .
}
& .\cobalt.exe serve -c input/_cobalt.yml -d _site $args
