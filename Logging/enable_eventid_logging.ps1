# Increase some windows logs to 3GB capacity
$Loglist = @('Microsoft-Windows-Sysmon/Operational','Microsoft-Windows-PowerShell/Operational','Security','Windows PowerShell')
foreach($log in $Loglist){
    $increaselog = Get-WinEvent -ListLog $log -ErrorAction SilentlyContinue
    if ($increaselog -ne $null){
        $increaselog.MaximumSizeInBytes = 3221225472
        $increaselog.SaveChanges()
    }
}

#Enable Logs
wevtutil sl Microsoft-Windows-TaskScheduler/Operational /e:true
wevtutil sl Microsoft-Windows-DriverFrameworks-UserMode/Operational /e:true

# Set account logon audit policy
auditpol /set /subcategory:'{0CCE923F-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
# Set computer account management audit policy
auditpol /set /subcategory:'{0CCE9236-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
# Set other account management events audit policy
auditpol /set /subcategory:'{0CCE923A-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
# Set security group management audit policy
auditpol /set /subcategory:'{0CCE9237-69AE-11D9-BED3-505054503030}' /success:enable /failure:enable
# Set user account management audit policy
auditpol /set /subcategory:'{0CCE9235-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
# Set plug and play audit policy
auditpol /set /subcategory:'{0cce9248-69ae-11d9-bed3-505054503030}'  /success:enable /failure:enable
# Set process creation audit policy
auditpol /set /subcategory:'{0CCE922B-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
# Enable command line auditing
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit /v ProcessCreationIncludeCmdLine_Enabled /f /t REG_DWORD /d 1
# Set RPC event audit policy
auditpol /set /subcategory:'{0CCE922E-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable

# Only for servers
# Check if machine is a server or workstation
$machineType = (Get-WmiObject Win32_ComputerSystem).Model
if ($server -eq "Server") {
    # Server audit policies
    auditpol /set /subcategory:'{0CCE922F-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9230-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9231-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9233-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9232-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9234-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9228-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9214-69AE-11D9-BED3-505054503030}'  /success:disable /failure:enable
    auditpol /set /subcategory:'{0CCE9210-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9211-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9212-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    #Set process termination audit policy
    auditpol /set /subcategory:'{0CCE922C-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    # Set audit token right adjustments audit policy (only for servers)
    auditpol /set /subcategory:'{0CCE924A-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    # DS Access
    auditpol /set /subcategory:'{0CCE923B-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE923C-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    # Object Access
    auditpol /set /subcategory:'{0CCE9222-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9221-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9243-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE921D-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE921F-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9244-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9225-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE921E-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
}
else{
    # Workstation audit policies
    auditpol /set /subcategory:'{0CCE922F-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9230-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9231-69AE-11D9-BED3-505054503030}'  /success:disable /failure:enable
    auditpol /set /subcategory:'{0CCE9233-69AE-11D9-BED3-505054503030}'  /success:disable /failure:enable
    auditpol /set /subcategory:'{0CCE9232-69AE-11D9-BED3-505054503030}'  /success:disable /failure:enable
    auditpol /set /subcategory:'{0CCE9234-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9228-69AE-11D9-BED3-505054503030}'  /success:disable /failure:enable
    auditpol /set /subcategory:'{0CCE9214-69AE-11D9-BED3-505054503030}'  /success:disable /failure:enable
    auditpol /set /subcategory:'{0CCE9210-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9211-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9212-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    # Object Access
    auditpol /set /subcategory:'{0CCE9224-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9226-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9227-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9245-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
    auditpol /set /subcategory:'{0CCE9220-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
}

# Logon/Logoff
auditpol /set /subcategory:'{0CCE9217-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
auditpol /set /subcategory:'{0CCE9216-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
auditpol /set /subcategory:'{0CCE9215-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
auditpol /set /subcategory:'{0CCE921C-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable
auditpol /set /subcategory:'{0CCE921B-69AE-11D9-BED3-505054503030}'  /success:enable /failure:enable



#Enable PowerShell Module logging
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging' -Name 'EnableModuleLogging' -Type DWord -Value 1
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames' -Name '*' -Type String -Value '*'

#Enable PowerShell Script Block logging
Set-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -Name 'EnableScriptBlockLogging' -Type DWord -Value 1


Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'EnableTranscripting' -Value 1
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'EnableInvocationHeader' -Value 1
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'OutputDirectory' -Value ""
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'EnableTranscripting' -Value 1
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'EnableInvocationHeader' -Value 1
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'OutputDirectory' -Value ""


# EventID 4688 with commandline details
# Enable Audit Process Creation audit policy
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -Name "ProcessCreation" -Value 1 -Type DWORD
# Enable Include command line in process creation events
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -Name "ProcessCreationIncludeCmdLine_Enabled" -Value 1 -Type DWORD

#Enable file access audit success events (Event ID 5145,4663,4660,4656,4658)
Auditpol /set /subcategory:"Detailed File Share" /success:enable
Auditpol /set /subcategory:"File System" /success:enable
#Enable file access audit failure events (Event ID 5145,4663,4660,4656,4658)
Auditpol /set /subcategory:"Detailed File Share" /failure:enable
Auditpol /set /subcategory:"File System" /failure:enable
#EventID 4656 - enable Handle Manipulation setting
Auditpol /set /subcategory:"Handle Manipulation" /success:enable
#Enable EventID 5136 logging
auditpol /set /subcategory:"Directory Service Changes" /success:enable
#Enable EventID logging 4656,4657,4660,4663 
auditpol /set /subcategory:"Registry" /success:enable /failure:enable
#Enable EventID logging 5156
auditpol /set /subcategory:"Filtering Platform Connection" /success:enable

#Work in progress
    # Set Account Logon to Audit Success and Failure
    auditpol /set /subcategory:"Account Logon" /success:enable /failure:enable
    # Set Logon/Logoff to Audit Success and Failure
    auditpol /set /subcategory:"Logon/Logoff" /success:enable /failure:enable
    # Set Account Management to Audit Success and Failure
    auditpol /set /subcategory:"Account Management" /success:enable /failure:enable
    # Set Detailed Tracking to Audit PNP Activity
    auditpol /set /subcategory:"Detailed Tracking" /success:enable /failure:enable
    # Set Privilege Use to Audit Sensitive Privilege Use to Audit Success and Failure
    auditpol /set /subcategory:"Privilege Use" /success:enable /failure:enable
