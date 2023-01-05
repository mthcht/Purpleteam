<#
  T1210 - Exploitation of Remote Services
  T1562.001 - Impair Defenses: Disable or Modify Tools
  Simple simulation script to enable SMB1 and SMB2  protocol on the system and revert the actions
  WannaCry uses an exploit in SMBv1 to spread itself to other remote systems on a network.
  NotPetya can use two exploits in SMBv1, EternalBlue and EternalRomance, to spread itself to other remote systems on the network.[
  /!\ SMBv1 should not be used 
#>


# Enable SMB1 on Workstaiton and server
Set-SmbServerConfiguration -EnableSMB1Protocol $true -Confirm:$false -ErrorAction SilentlyContinue
Enable-WindowsOptionalFeature -Online -FeatureName smb1protocol -NoRestart -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB1 -Type DWORD -Value 1 -Force -ErrorAction SilentlyContinue

#Enable SMB2 on Workstation and server
Set-SmbServerConfiguration -EnableSMB2Protocol $true -Confirm:$false -ErrorAction SilentlyContinue
Enable-WindowsOptionalFeature -Online -FeatureName smb2protocol -NoRestart -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB2 -Type DWORD -Value 1 -Force -ErrorAction SilentlyContinue

try{
    #Disable SM1 and SMB2
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue  -NoRestart
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB2 -Type DWORD -Value 0 -Force -ErrorAction SilentlyContinue
    Set-SmbServerConfiguration -EnableSMB2Protocol $false -ErrorAction SilentlyContinue -Confirm:$false
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -ErrorAction SilentlyContinue -Confirm:$false

    }
catch{
    Write-Host -ForegroundColor Red "[failed] Error Cannot Disable : $_"
}


# Restart the computer for changes to take effect
# Restart-Computer
