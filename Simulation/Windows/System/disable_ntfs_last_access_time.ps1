<#
     T1562.001 - Impair Defenses: Disable or Modify Tools
     T1070.009 - Indicator Removal: Clear Persistence
     Disable NTFS Last access time logging
#>

try{
    Write-Host -ForegroundColor Cyan "Disabling NTFS Last access time in registry...."
    $RegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    $CurrentValue = (Get-ItemProperty -Path $RegistryPath -Name NtfsDisableLastAccessUpdate).NtfsDisableLastAccessUpdate
    if ($CurrentValue -ne 1){
        Set-ItemProperty -Path $RegistryPath -Name NtfsDisableLastAccessUpdate -Value 1
        if($? -eq $true){
            Write-Host -ForegroundColor Green "Success: NTFS Last access time disbaled, NtfsDisableLastAccessUpdate set to" (Get-ItemProperty -Path $RegistryPath -Name NtfsDisableLastAccessUpdate).NtfsDisableLastAccessUpdate
        }
        else{
            Write-Host -ForegroundColor Red "Error: cannot set value to 1, current value of NtfsDisableLastAccessUpdate =" (Get-ItemProperty -Path $RegistryPath -Name NtfsDisableLastAccessUpdate).NtfsDisableLastAccessUpdate
        }
    }
    else{
        Write-Host -ForegroundColor Yellow "NtfsDisableLastAccessUpdate is already disabled"
    }
    Write-Host -ForegroundColor Cyan "Revert action: Setting NtfsDisableLastAccessUpdate value to 2 (enable)"
    Set-ItemProperty -Path $RegistryPath -Name NtfsDisableLastAccessUpdate -Value 2
    if($? -eq $true){
        Write-Host -ForegroundColor Green "Success: NTFS Last access time enabled, NtfsDisableLastAccessUpdate set to ="(Get-ItemProperty -Path $RegistryPath -Name NtfsDisableLastAccessUpdate).NtfsDisableLastAccessUpdate
    }
    else{
        Write-Host -ForegroundColor Red "Error: Impossible to revert-action - NtfsDisableLastAccessUpdate value =" (Get-ItemProperty -Path $RegistryPath -Name NtfsDisableLastAccessUpdate).NtfsDisableLastAccessUpdate
    }
}
catch{
    Write-Host -ForegroundColor Red "Error: $_"
}

try{
    Write-Host -ForegroundColor Cyan "`n`nDisabling NTFS Last access time with fsutil..."
    &"fsutil" behavior set disablelastaccess 1
    $CurrentValue = &"fsutil" behavior query disablelastaccess
    if($CurrentValue -like "DisableLastAccess = 1*"){
        Write-Host -ForegroundColor Green "Success: NTFS Last access time disbaled, current value: `'$CurrentValue`'"
    }
    else{
        Write-Host -ForegroundColor Red "Error: NTFS Last access time is not disabeld, current value: `'$CurrentValue`'"
    }
    Write-Host -ForegroundColor Cyan "Revert action: Setting disablelastaccess value to 0 (enable)"
    &"fsutil" behavior set disablelastaccess 0
    $CurrentValue = &"fsutil" behavior query disablelastaccess
    if($CurrentValue -like "DisableLastAccess = 0*"){
        Write-Host -ForegroundColor Green "Success: NTFS Last access enabled, current value: `'$CurrentValue`'"
    }
    else{
        Write-Host -ForegroundColor Red "Error: NTFS Last access time is not enabled, current value: `'$CurrentValue`'"
    }
}
catch{
    Write-Host "ok"
}
