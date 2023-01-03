<# 
   T1021.001 - Remote Services: Remote Desktop Protocol
   T1112 - Modify Registry
   Attackers would want to log in to a host using RDP, but the user has an active session. 
   Allow the users to have mutliple sessions opened, with this script:
#>

$reg_key = "HKLM:\System\CurrentControlSet\Control\TerminalServer"
$name = "fSingleSessionPerUser"
$value = 0
$type = "DWord"
$reg_key_value = Get-ItemProperty -Path $reg_key
if (!(Test-Path $reg_key)) {
    try{
        Write-Host -ForegroundColor Red "The registry key does not exist, the system may not be able to allow multiple rdp session, creating it anyway to simulate the behavior"
        New-Item -Path $reg_key -Force | Out-Null
        Set-ItemProperty -Path $reg_key -Name $name -Value $value -Type $type
        # reverse the action
        Remove-ItemProperty -Path $reg_key -Name $name
    }
    catch{
        Write-Host "An error occurred:"
        Write-Host $_
    } 
}
else{
    if((Get-ItemProperty -Path $reg_key -Name $name).$name -ne $value){
        {
            try{
                Set-ItemProperty -Path $reg_key -Name $name -Value $value -Type $type
                Write-Host -ForegroundColor Green "$reg_key is now configured to enable multilpe rdp sessions:`n"
                # reverse the action
                Set-ItemProperty -Path $reg_key -Name $name -Value 1 -Type $type
            }
            catch{
                Write-Host "An error occurred:"
                Write-Host $_
            } 
        }
    }
    else{
        Write-Host -ForegroundColor Green "$reg_key is already configured to enable multilpe rdp sessions:`n"
        $reg_key_value
    }
    
}
