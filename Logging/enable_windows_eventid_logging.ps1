
Start-Transcript -Path "$env:tmp\enablepolicies_traces.log" -Append

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

#From W10 with exploit guard, log process creation for some process, will be available in Microsoft-Windows-Security-Mitigations/Kernel Mode
Set-ProcessMitigation -Name cmd.exe -Disable DisallowChildProcessCreation -Enable AuditChildProcess
Set-ProcessMitigation -Name powershell.exe -Disable DisallowChildProcessCreation -Enable AuditChildProcess
Set-ProcessMitigation -Name powershell_ise.exe -Disable DisallowChildProcessCreation -Enable AuditChildProcess

# Enable policies logging success and failures
$list_policy = @("'{0CCE923F-69AE-11D9-BED3-505054503030}'","'{0CCE9236-69AE-11D9-BED3-505054503030}'","'{0CCE923A-69AE-11D9-BED3-505054503030}'","'{0CCE9237-69AE-11D9-BED3-505054503030}'","'{0CCE9235-69AE-11D9-BED3-505054503030}'","'{0cce9248-69ae-11d9-bed3-505054503030}'","'{0CCE922B-69AE-11D9-BED3-505054503030}'","'{0CCE922E-69AE-11D9-BED3-505054503030}'","'{0CCE9217-69AE-11D9-BED3-505054503030}'","'{0CCE9216-69AE-11D9-BED3-505054503030}'","'{0CCE9215-69AE-11D9-BED3-505054503030}'","'{0CCE921C-69AE-11D9-BED3-505054503030}'","'{0CCE921B-69AE-11D9-BED3-505054503030}'")
foreach ($policy in $list_policy){
    & "Auditpol" /set /subcategory:$policy /success:enable /failure:enable
}

#Enable other policies
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

$machineType = (Get-WmiObject Win32_ComputerSystem).Model
if ($machineType -like "*Server*") {
    $list_policy_server_enable_sucess_and_failures = @("'{0CCE922F-69AE-11D9-BED3-505054503030}'","'{0CCE9230-69AE-11D9-BED3-505054503030}'","'{0CCE9231-69AE-11D9-BED3-505054503030}'","'{0CCE9233-69AE-11D9-BED3-505054503030}'","'{0CCE9234-69AE-11D9-BED3-505054503030}'","'{0CCE9228-69AE-11D9-BED3-505054503030}'","'{0CCE9210-69AE-11D9-BED3-505054503030}'","'{0CCE9211-69AE-11D9-BED3-505054503030}'","'{0CCE9212-69AE-11D9-BED3-505054503030}'","'{0CCE922C-69AE-11D9-BED3-505054503030}'","'{0CCE924A-69AE-11D9-BED3-505054503030}'","'{0CCE924A-69AE-11D9-BED3-505054503030}'","'{0CCE923B-69AE-11D9-BED3-505054503030}'","'{0CCE923C-69AE-11D9-BED3-505054503030}'","'{0CCE9222-69AE-11D9-BED3-505054503030}'","'{0CCE9221-69AE-11D9-BED3-505054503030}'","'{0CCE9243-69AE-11D9-BED3-505054503030}'","'{0CCE921D-69AE-11D9-BED3-505054503030}'","'{0CCE921F-69AE-11D9-BED3-505054503030}'","'{0CCE9244-69AE-11D9-BED3-505054503030}'","'{0CCE9225-69AE-11D9-BED3-505054503030}'","'{0CCE921E-69AE-11D9-BED3-505054503030}'")
    $list_policy_server_disable_success_enable_failure = @("'{0CCE9214-69AE-11D9-BED3-505054503030}'")
    # Server audit policies
    foreach ($policy in $list_policy_server_enable_sucess_and_failures){
        auditpol /set /subcategory:$policy /success:enable /failure:enable
    }
    foreach ($policy in $list_policy_server_disable_success_enable_failure){
        auditpol /set /subcategory:$policy /success:disable /failure:enable
    }
}
else{
    $list_policy_workstation_enable_sucess_and_failures = @("'{0CCE922F-69AE-11D9-BED3-505054503030}'","'{0CCE9230-69AE-11D9-BED3-505054503030}'","'{0CCE9234-69AE-11D9-BED3-505054503030}'","'{0CCE9210-69AE-11D9-BED3-505054503030}'","'{0CCE9211-69AE-11D9-BED3-505054503030}'","'{0CCE9212-69AE-11D9-BED3-505054503030}'","'{0CCE9224-69AE-11D9-BED3-505054503030}'","'{0CCE9226-69AE-11D9-BED3-505054503030}'","'{0CCE9227-69AE-11D9-BED3-505054503030}'","'{0CCE9245-69AE-11D9-BED3-505054503030}'","'{0CCE9220-69AE-11D9-BED3-505054503030}'")
    $list_policy_workstation_disable_success_enable_failure = @("'{0CCE9231-69AE-11D9-BED3-505054503030}'","'{0CCE9233-69AE-11D9-BED3-505054503030}'","'{0CCE9232-69AE-11D9-BED3-505054503030}'","'{0CCE9228-69AE-11D9-BED3-505054503030}'","'{0CCE9214-69AE-11D9-BED3-505054503030}'")
    foreach ($policy in $list_policy_workstation_enable_sucess_and_failures){
        auditpol /set /subcategory:$policy /success:enable /failure:enable
    }
    foreach ($policy in $list_policy_workstation_disable_success_enable_failure){
        auditpol /set /subcategory:$policy /success:disable /failure:enable
    } 
}

if(-not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit")){
    Write-Host -ForegroundColor Cyan "RegKey HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit is not found. Creating it."    
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -Force -Verbose
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit' -Name ProcessCreationIncludeCmdLine_Enabled -Type DWord -Value 1 -Verbose
}
else{
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit' -Name ProcessCreationIncludeCmdLine_Enabled -Type DWord -Value 1 -Verbose
}

if(-not (Test-Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging")){
    Write-Host -ForegroundColor Cyan "RegKey HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging is not found. Creating it."
    New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Force -Verbose
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging' -Name 'EnableModuleLogging' -Type DWord -Value 1 -Verbose
}
else{
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging' -Name 'EnableModuleLogging' -Type DWord -Value 1 -Verbose
}

#Enable PowerShell Module logging
if(-not (Test-Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames")){
    Write-Host -ForegroundColor Cyan "RegKey HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames is not found. Creating it."
    New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames" -Force -Verbose
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames' -Name '*' -Type String -Value '*' -Verbose
}
else{
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames' -Name '*' -Type String -Value '*' -Verbose
}

#Enable PowerShell Script Block logging
if(-not (Test-Path "HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging")){
    Write-Host -ForegroundColor Cyan "RegKey HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging is not found. Creating it."
    New-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Force -Verbose
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -Name 'EnableScriptBlockLogging' -Type DWord -Value 1 -Verbose
}
else{
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -Name 'EnableScriptBlockLogging' -Type DWord -Value 1 -Verbose
}

#Enable Powershell Transcript
if(-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription")){
    Write-Host -ForegroundColor Cyan "RegKey HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription is not found. Creating it."
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" -Force -Verbose
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'EnableTranscripting' -Type DWord -Value 1 -Verbose
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'EnableInvocationHeader' -Value 1 -Verbose
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'OutputDirectory' -Value "" -Verbose
}
else{
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'EnableTranscripting' -Type DWord -Value 1 -Verbose
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'EnableInvocationHeader' -Value 1 -Verbose
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'OutputDirectory' -Value "" -Verbose
}

if(-not (Test-Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription")){
    Write-Host -ForegroundColor Cyan "RegKey HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription is not found. Creating it."
    New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription" -Force -Verbose
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'EnableTranscripting' -Type DWord -Value 1 -Verbose
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'EnableInvocationHeader' -Value 1 -Verbose
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'OutputDirectory' -Value "" -Verbose
}
else{
    #Enable Powershell Transcript
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'EnableTranscripting' -Type DWord -Value 1 -Verbose
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'EnableInvocationHeader' -Value 1 -Verbose
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription' -Name 'OutputDirectory' -Value "" -Verbose
}

# Enable Audit Process Creation audit policy (ventID 4688 with commandline details)
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -Name "ProcessCreation" -Value 1 -Type DWORD -Verbose

# Enable Include command line in process creation events
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -Name "ProcessCreationIncludeCmdLine_Enabled" -Value 1 -Type DWORD -Verbose

Stop-Transcript
