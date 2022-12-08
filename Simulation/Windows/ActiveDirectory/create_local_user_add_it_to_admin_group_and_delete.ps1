
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$username,

    [Parameter(Mandatory=$true)]
    [string]$password,
    
    [Parameter(Mandatory=$true)]
    [string]$method
)


# We import the ActiveDirectory module without the need to install it on the current computer, the dll has been extracted from a Windows 10 x64 with RSAT installed
# technique used by real attackers
Import-Module .\Microsoft.ActiveDirectory.Management.dll


$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$adminGroup = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $adminGroup.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

if ($isAdmin -eq $true) 
{
    Write-Host "Running with Admin privileges"
} 
else 
{
    Write-Host "Not running with Admin privileges"
    exit
}



Function Admin_method1 {
    Param (
        [string]$UserName,
        [string]$Password
    ) 
    #Create user account
    net user /add $UserName $Password
    #Add user to local admins
    net localgroup $Admin_GroupName $UserName /add
    net localgroup $Admin_GroupName $UserName /delete
    net user /delete $UserName
}

Function Admin_method2 {
    Param (
        [string]$UserName,
        [string]$Password
    )
    # Create user account
    New-ADUser -Name $UserName -AccountPassword (ConvertTo-SecureString -AsPlainText $Password -Force) -Enabled $true -ChangePasswordAtLogon $true
    # Add user to local admins group
    Add-ADGroupMember -Identity $Admin_GroupName -Members $UserName
    Remove-ADGroupMember -Identity $Admin_GroupName -Members $UserName
    Remove-ADUser -Identity $UserName
}

$Admin_GroupName = (Get-LocalGroup -SID S-1-5-32-544 | Select-Object Name).name

if ($method =1){ Admin_method1 -UserName $username -Password $password}
if ($method =2){ Admin_method2 -UserName $username -Password $password}
