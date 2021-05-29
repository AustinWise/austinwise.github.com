$ProgressPreference = 'SilentlyContinue'
if (!(Test-Path -Path .\cobalt.exe)) {
    Write-Output "Downloading cobalt.exe"
    Invoke-WebRequest -UseBasicParsing -OutFile cobalt.exe https://github.com/AustinWise/cobalt.rs/releases/download/austin-v1/cobalt.exe
}
$hash = Get-FileHash -Algorithm SHA256 .\cobalt.exe
if ($hash.Hash -ne "3BECCD1EDE29D5C9F53DA05C99BA6988F2D52ED786EF7654DC9F07698CF4CA99") {
    Remove-Item .\cobalt.exe
    throw "failed to valdate hash"
}
& .\cobalt.exe serve -c input/_cobalt.yml -d _site
