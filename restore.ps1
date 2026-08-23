$ProgressPreference = 'SilentlyContinue'
if (!(Test-Path -Path .\cobalt\cobalt.exe)) {
    Write-Output "Downloading cobalt"
    Invoke-WebRequest -UseBasicParsing -OutFile cobalt.zip https://github.com/cobalt-org/cobalt.rs/releases/download/v0.20.4/cobalt-v0.20.4-x86_64-pc-windows-msvc.zip
    $hash = Get-FileHash -Algorithm SHA256 .\cobalt.zip
    if ($hash.Hash -ne "19C4ED116C4336D4C3BF0826AC11EDB66A43713445D747A9357E78E9B1DEC5E8") {
        throw "Unexpected hash: $hash"
    }
    if (-not (test-path cobalt)) {
        mkdir cobalt
    }
    Expand-Archive -Path .\cobalt.zip -DestinationPath cobalt
}
