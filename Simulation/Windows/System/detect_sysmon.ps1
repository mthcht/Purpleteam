<#
   T1518.001 - Software Discovery: Security Software Discovery
   T1057 - Process Discovery
   T1007 - System Service Discovery
   T1082 - System Information Discovery
#>

$sysmon_process = Get-Process | Where-Object { $_.ProcessName -eq "Sysmon" }
$sysmon_service = (Get-CimInstance win32_service -Filter "Description = 'System Monitor service'") | Select-Object ProcessId,State
$sysmon_service2 = (Get-Service | where-object {$_.DisplayName -like "*Sysmo*"})| Select-Object Name,Status
$sysmon_evtx = reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Sysmon/Operational
$sysmon_driver_name = fltmc.exe | Select-String "sysmon"
$sysmon_driver_altitude = fltmc.exe | Select-String "385201"
$sysinternals_current_user = Get-ChildItem HKCU:\Software\Sysinternals 
$sysinternal_sysmon_installed_current_user = $sysinternals_current_user | Select-String "System Monitor" 
$sysmon_command = Get-Command sysmon*
$sysmon_location = $sysmon_command | Select-Object -ExpandProperty Source
$sysmon_config = powershell -Command "& $sysmon_location -c"
# This last one can take a long time (disable by default) but nice to detect last sysmon eventlog 
# $latest_sysmon_event = Get-WinEvent -LogName Microsoft-Windows-Sysmon/Operational | Sort-Object TimeCreated -Descending | Select-Object -First 1 -Property TimeCreated


if ($sysmon_driver_altitude){
    Write-Host -ForegroundColor DarkYellow "Sysmon driver is loaded: `n $sysmon_driver_altitude `nThe altitude 385201 for sysmon cannot be changed so it is the best way to know if sysmon is active on the system `n`n"
}
if ($sysmon_process){
    Write-Host -ForegroundColor DarkYellow "Sysmon process found: `n $sysmon_process `n`n"
}
if ($sysmon_service){
    Write-Host -ForegroundColor DarkYellow "Sysmon service found (method1): `n $sysmon_service `n`n"
}
if ($sysmon_service2){
    Write-Host -ForegroundColor DarkYellow "Sysmon service found (method2): `n $sysmon_service2 `n`n"
}
if ($sysmon_evtx){
    Write-Host -ForegroundColor DarkYellow "Sysmon Event Channel found: `n $sysmon_evtx `n`n"
}
if ($sysmon_driver_name){
    Write-Host -ForegroundColor DarkYellow "Sysmon driver name found: `n $sysmon_driver_name `n`n"
}
if ($latest_sysmon_event){
    Write-Host -ForegroundColor DarkYellow "Sysmon last eventlog: `n $latest_sysmon_event `n`n"
}
if ($sysinternal_sysmon_installed_current_user){
    Write-Host -ForegroundColor DarkYellow "Sysmon installed for current user: `n $sysinternal_sysmon_installed_current_user `n`n"
}
if ($sysmon_location){
    Write-Host -ForegroundColor DarkYellow "Sysmon location found: `n $sysmon_location `n`n"
}
if ($sysmon_config){
    Write-Host -ForegroundColor DarkYellow "Sysmon configuration found: `n $sysmon_config `n`n"
}
