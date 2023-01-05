<#
    T1543 - Create or Modify System Process
    T1562.001 - Impair Defenses: Disable or Modify Tools
    T1021.001 - Remote Services: Remote Desktop Protocol
    Script that will weaken RDP settings, setting these values will allow easier spoofing and MITM and Bruteforce attacks.
    NLA must be disable for example if we want to spoof the client hostname authenticating with kerberos.
#>

$regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"

# Get state of RDP settings
$UserAuthentication_state = (Get-ItemProperty -Path $regKey -Name "UserAuthentication").UserAuthentication
$SecurityLayer_state = (Get-ItemProperty -Path $regKey -Name "SecurityLayer").SecurityLayer
$EnableCredSSP_state = (Get-ItemProperty -Path $regKey -Name "EnableCredSSP").EnableCredSSP


# We do not check if the state is already 0 because we want to simulate the behavior here
try{
    Write-Host -ForegroundColor Green "Disable Network Level Authentication - 'UserAuthentication' to 0: `nSpecifies that Network-Level user authentication is not required before the remote desktop connection is established."
    Set-ItemProperty -Path $regKey -Name "UserAuthentication" -Value 0
    Get-ItemProperty -Path $regKey -Name "UserAuthentication"
    
    Write-Host -ForegroundColor Green "SecurityLayer to 0 `nSpecifies that RDP protocol is used by the server and the client for authentication before a remote desktop connection is established"
    Set-ItemProperty -Path $regKey -Name "SecurityLayer" -Value 0
    Get-ItemProperty -Path $regKey -Name "SecurityLayer"

    Write-Host -ForegroundColor Green "Disable Credential Security Support Provider (CredSSP) - EnableCredSSP to 0"
    Set-ItemProperty -Path $regKey -Name "EnableCredSSP" -Value 0
    Get-ItemProperty -Path $regKey -Name "EnableCredSSP"

    # Set the values back to what they were before, if they were not set, delete the created key"
    if($UserAuthentication_state){
        Set-ItemProperty -Path $regKey -Name "UserAuthentication" -Value $UserAuthentication_state
        Get-ItemProperty -Path $regKey -Name "UserAuthentication"
    }
    else{
        Remove-ItemProperty -Path $regKey -Name "UserAuthentication"
    }
    if($SecurityLayer_state){
        Set-ItemProperty -Path $regKey -Name "SecurityLayer" -Value $SecurityLayer_state
        Get-ItemProperty -Path $regKey -Name "SecurityLayer"
    }
    else{
        Remove-ItemProperty -Path $regKey -Name "SecurityLayer"
    }
    if($EnableCredSSP_state){
        Set-ItemProperty -Path $regKey -Name "EnableCredSSP" -Value $EnableCredSSP_state
        Get-ItemProperty -Path $regKey -Name "EnableCredSSP"
    }
    else{
        Remove-ItemProperty -Path $regKey -Name "EnableCredSSP"
    }
}
catch{
    Write-Host -ForegroundColor Red "[failed] Error: _$"
}
