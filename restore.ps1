$ProgressPreference = 'SilentlyContinue'
if (!(Test-Path -Path .\cobalt\cobalt.exe)) {
    Write-Output "Downloading cobalt"
    Invoke-WebRequest -UseBasicParsing -OutFile cobalt.zip https://github.com/cobalt-org/cobalt.rs/releases/download/v0.20.0/cobalt-v0.20.0-x86_64-pc-windows-msvc.zip
    $hash = Get-FileHash -Algorithm SHA256 .\cobalt.zip
    if ($hash.Hash -ne "B74E56406B6D930A4B932490FB637C7E46A8E54C6FC2334093A0BCD4E07E9799") {
        throw "Unexpected hash: $hash"
    }
    if (-not (test-path cobalt)) {
        mkdir cobalt
    }
    Expand-Archive -Path .\cobalt.zip -DestinationPath cobalt
}
