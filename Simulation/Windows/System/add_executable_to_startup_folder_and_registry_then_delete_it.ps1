<# 
   T1070.009 - Indicator Removal: Clear Persistence
   T1547.001 - Boot or Logon Autostart Execution: Registry Run Keys / Startup Folder
   Create an empty .exe file and add it to startup folder and startup registry keys
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

try{
    $currentUser = [Environment]::UserName

    # Create exe files
    $FileName = "Purpleteam.exe"
    $FilePath = "C:\Windows\Temp\$FileName"
    $startuppath = "C:\Users\$currentUser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\$FileName"
    New-Item -Path $FilePath -ItemType File -Force
    New-Item -Path $startuppath -ItemType File -Force

    # Add the executable to registry
    $regKey = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
    $regKey2 = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
    $regKey3 = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\'
    $regkeylist = @('Run','RunOnce','RunServices','RunServicesOnce')
    $reghivelist = @('HKLM:','HKCU:')
    $regName = 'Purpleteam'
    foreach ($reghive in $reghivelist){
        foreach ($regkey in $regkeylist){
            Write-Host -ForegroundColor Cyan "`nSetting registry key value for $reghive\Software\Microsoft\Windows\CurrentVersion\$regkey..."
            if (-not (Test-Path "$reghive\Software\Microsoft\Windows\CurrentVersion\$regkey")){
                New-Item  -Path "$reghive\Software\Microsoft\Windows\CurrentVersion\$regkey" -Force -Verbose
            }
            Set-ItemProperty -Path "$reghive\Software\Microsoft\Windows\CurrentVersion\$regkey" -Name $regName -Value $startuppath -Force
            $result = Get-ItemProperty -Path "$reghive\Software\Microsoft\Windows\CurrentVersion\$regkey" -Name $regName
            if($result){
                Write-Host -ForegroundColor Green "Success: Executable added to registry $reghive\Software\Microsoft\Windows\CurrentVersion\$regkey"
                Write-Host -ForegroundColor Cyan "Revert action: Removing $reghive\Software\Microsoft\Windows\CurrentVersion\$regkey value $regName now..."
                Remove-ItemProperty -Path "$reghive\Software\Microsoft\Windows\CurrentVersion\$regkey" -Name $regName -Force -Verbose
                if($? -eq $true){
                    Write-Host -ForegroundColor Green "Revert action: $reghive\Software\Microsoft\Windows\CurrentVersion\$regkey value $regName removed..."
                }
                else{
                    Write-Host -ForegroundColor Yellow "Warning: $reghive\Software\Microsoft\Windows\CurrentVersion\$regkey $regkey value could not be removed" 
                }
            }
            else{
                Write-Host -ForegroundColor Red "Failed: Executable could not be added to registry $reghive\Software\Microsoft\Windows\CurrentVersion\$regkey"
            }

        }
    }
    # Delete exe files
    Remove-Item -Path $FilePath,$startuppath -Force -Verbose
}

catch{
    Write-Host -ForegroundColor Red "Error: $_"
}

Stop-Transcript
