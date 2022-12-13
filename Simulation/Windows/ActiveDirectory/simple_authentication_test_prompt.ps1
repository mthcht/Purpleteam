# Trigger Honeypot Accounts connection detections
# We import the ActiveDirectory module without the need to install it on the current computer, the dll has been extracted from a Windows 10 x64 with RSAT installed
# technique used by real attackers
Import-Module .\Microsoft.ActiveDirectory.Management.dll

#Set credentials
$cred = Get-Credential

#Try authenticate user
Try
{
    $user = Get-ADUser -Identity $cred.UserName -Credential $cred
    Write-Host "User $($user.Name) authenticated successfully"    
}
Catch
{
    Write-Host "Authentication failed"
}
