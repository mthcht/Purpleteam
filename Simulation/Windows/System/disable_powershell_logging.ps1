<#
    T1562.002 - Impair Defenses: Disable Windows Event Logging
    T1562.003 - Impair Defenses: Impair Command History Logging
    T1112 - Modify Registry
    Enable or Disable (disable by default) powershell logging capacities 
#>

param(
    [switch]$enable,
    [switch]$disable
)

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

$regkey_scriptblock = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
$regkey_module = "HKLM:\Software\Policies\Microsoft\Windows\Powershell\ModuleLogging"

if ($enable){
    $setvalue = 1
    $setvaluestring = "Enabling"
}
elseif ($disable){
    $setvalue = 0
    $setvaluestring = "Disabling"
}
else{
    Write-Host -ForegroundColor Cyan "No action specified, Disabling by default"
    $setvalue = 0
    $setvaluestring = "Disabling"
}

try {
    Write-Host -ForegroundColor Cyan "$setvaluestring Powershell ScriptBlockLogging..."
    if (-not (Test-Path $regkey_scriptblock)){
        Write-Host -ForegroundColor Cyan "Creating registry key $regkey_scriptblock ..."
        New-Item -Path "$regkey_scriptblock" -Force -Verbose
    }
    if (Test-Path $regkey_scriptblock){
        if (Get-ItemProperty -Path "$regkey_scriptblock" -Name "EnableScriptBlockLogging" -ErrorAction SilentlyContinue) {
            Write-Host -ForegroundColor Cyan "Registry key $regkey_scriptblock exist, setting 'EnableScriptBlockLogging' value to $setvalue ..."
            Set-ItemProperty -Path "$regkey_scriptblock" -Name "EnableScriptBlockLogging" -Value $setvalue -Force -Verbose
        }
        else {
            Write-Host -ForegroundColor Cyan "Registry key $regkey_scriptblock exist, creating 'EnableScriptBlockLogging' key with value $setvalue ..."
            New-ItemProperty -Path $regkey_scriptblock -Name "EnableScriptBlockLogging" -Value $setvalue -Force -Verbose
        }
        $result = (Get-ItemProperty -Path "$regkey_scriptblock" | Select-Object -ExpandProperty EnableScriptBlockLogging)
        if ($result -eq $setvalue) {
            Write-Host -ForegroundColor Green "Success: Registry key $regkey_scriptblock created and EnableScriptBlockLogging value set to $setvalue"
        }
        else {
            Write-Host -ForegroundColor Red "Failed: Registry key $regkey_scriptblock created but EnableScriptBlockLogging value could not be set to $setvalue"
        }
    }
    else{
        Write-Host -ForegroundColor Red "Failed: Registry key $regkey_scriptblock does not exist and could not be created, something went wrong..."
    }
    Write-Host -ForegroundColor Cyan "$setvaluestring Powershell ModuleLogging..."
    if (-not (Test-Path $regkey_module)){
        Write-Host -ForegroundColor Cyan "Creating registry key $regkey_module ..."
        New-Item -Path "$regkey_module" -Force -Verbose
    }
    if (Test-Path $regkey_module){
        if (Get-ItemProperty -Path "$regkey_module" -Name "EnableModuleLogging" -ErrorAction SilentlyContinue) {
            Write-Host -ForegroundColor Cyan "Registry key $regkey_module exist, setting 'EnableModuleLogging' value to $setvalue ..."
            Set-ItemProperty -Path "$regkey_module" -Name "EnableModuleLogging" -Value $setvalue -Force -Verbose
        }
        else {
            Write-Host -ForegroundColor Cyan "Registry key $regkey_module exist, creating 'EnableModuleLogging' key with value $setvalue ..."
            New-ItemProperty -Path $regkey_module -Name "EnableModuleLogging" -Value $setvalue -Force -Verbose
        }
        $result = (Get-ItemProperty -Path "$regkey_module" | Select-Object -ExpandProperty EnableModuleLogging)
        if ($result -eq $setvalue) {
            Write-Host -ForegroundColor Green "Success: Registry key $regkey_module created and EnableModuleLogging value set to $setvalue"
        }
        else {
            Write-Host -ForegroundColor Red "Failed: Registry key $regkey_module created but EnableModuleLogging value could not be set to $setvalue"
        }
    }
    else{
        Write-Host -ForegroundColor Red "Failed: Registry key $regkey_module does not exist and could not be created, something went wrong..."
    }
}
catch {
    Write-Host -ForegroundColor Red "Error: $_"
}

Stop-Transcript
