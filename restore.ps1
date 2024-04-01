$ProgressPreference = 'SilentlyContinue'
if (!(Test-Path -Path .\cobalt\cobalt.exe)) {
    Write-Output "Downloading cobalt"
    Invoke-WebRequest -UseBasicParsing -OutFile cobalt.zip https://github.com/cobalt-org/cobalt.rs/releases/download/v0.19.2/cobalt-v0.19.2-x86_64-pc-windows-msvc.zip
    $hash = Get-FileHash -Algorithm SHA256 .\cobalt.zip
    if ($hash.Hash -ne "1FAE07E4D2CBD02F08297C0A71B36F7CB10963A0AA2AFC7F5EC96AE36D6DFD2A") {
        throw "Unexpected hash: $hash"
    }
    if (-not (test-path cobalt)) {
        mkdir cobalt
    }
    Expand-Archive -Path .\cobalt.zip -DestinationPath cobalt
}
