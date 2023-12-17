$ProgressPreference = 'SilentlyContinue'
if (!(Test-Path -Path .\cobalt\cobalt.exe)) {
    Write-Output "Downloading cobalt"
    Invoke-WebRequest -UseBasicParsing -OutFile cobalt.zip https://github.com/cobalt-org/cobalt.rs/releases/download/v0.19.0/cobalt-v0.19.0-x86_64-pc-windows-msvc.zip
    $hash = Get-FileHash -Algorithm SHA256 .\cobalt.zip
    if ($hash.Hash -ne "2170706C96F7685D83AD024B2CFE340CEA2B6558775C31C0A3DD6F93DEB794D2") {
        throw "Unexpected hash: $hash"
    }
    if (-not (test-path cobalt)) {
        mkdir cobalt
    }
    Expand-Archive -Path .\cobalt.zip -DestinationPath cobalt
}
