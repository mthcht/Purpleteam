<#
    T1562.001 - Impair Defenses: Disable or Modify Tools
    T1098 - Account Manipulation
    T1112 - Modify Registry
    .SYNOPSIS
        This script will set the DsrmAdminLogonBehavior registry key to 2 (accept the logon attempt) and then revert the change to the recommended value 1 (deny the logon attempt).
        HKLM:\System\CurrentControlSet\Control\Lsa\DsrmAdminLogonBehavior is a registry key used for controlling the behavior of administrative logons for Domain Controllers.
        It controls the behavior of Domain Controllers when a local administrator logs on.
        The values for this key determine whether or not the Domain Controller will accept or deny the logon attempt.
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

$regpath = 'HKLM:\System\CurrentControlSet\Control\Lsa'
$regkey = 'HKLM:\System\CurrentControlSet\Control\Lsa\DsrmAdminLogonBehavior'
$regkeyname = 'DsrmAdminLogonBehavior'

try {
    Write-Host -ForegroundColor Cyan "[Info] Setting $regkey to value 2, the Domain Controller will accept the logon attempt of local admins"
    if (-not (Test-Path "$regkey")){
        write-Host -ForegroundColor Yellow "[Warning] $regkey does not exist, creating key $regkey with value 2"
        New-Item  -Path $regpath -Name $regkeyname -Value 2 -Force -Verbose
    }
    else{
        Write-Host -ForegroundColor Cyan "[Info] Registry key $regkey exist"
    }
    $result = Get-ItemProperty -Path $regpath -Name $regkeyname -Verbose    
    if($result){
        Write-Host -ForegroundColor Green "[Info] Registry key $regkey exist and value is `'$($result.DsrmAdminLogonBehavior)`'"
        if($result.DsrmAdminLogonBehavior -eq 2){
            Write-Host -ForegroundColor Green "[Success] Registry key $regkey value is already set to 2"
        }
        else{
            Write-Host -ForegroundColor Cyan "[Info] Setting registry key $regkey value to 2..."
            Set-ItemProperty -Path $regpath -Name $regkeyname -Value 2 -Force -Verbose
            $result = Get-ItemProperty -Path $regpath -Name $regkeyname -Verbose
            if($result.DsrmAdminLogonBehavior -eq 2){
                Write-Host -ForegroundColor Green "[Success] Registry key $regkey value set to 2"
            }
            else{
                Write-Host -ForegroundColor Red "[Error] Failed to set registry key $regkey value to 2"
            }
        }
    }
    else{
        Write-Host -ForegroundColor Red "[Error] Failed to create registry key $regkey"
    }
    Write-Host -ForegroundColor Cyan "[Info] Reverting the change, applying recommended value 1:"
    Set-ItemProperty -Path $regpath -Name $regkeyname -Value 1 -Force -Verbose
    $result = Get-ItemProperty -Path $regpath -Name $regkeyname -Verbose
    if($result.DsrmAdminLogonBehavior -eq 1){
        Write-Host -ForegroundColor Green "[Success] Registry key $regkey value set back to 1 (recommended value)"
    }
    else{
        Write-Host -ForegroundColor Yellow "[Warning] Failed to set registry key $regkey value back to 1, something went wrong..."
    }
}
catch {
    Write-Host -ForegroundColor Red "`n[Erorr] $_"
}

Stop-Transcript -Verbose
