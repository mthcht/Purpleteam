<#
    T1070.003 - Indicator Removal: Clear Command History
    Backup powershell History and clear powershell history for all users
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

$dumpfile = "$env:tmp\powershell_history_backup"

try{
    $users = Get-ChildItem -Path C:\Users
    if ($users){
        ForEach ($user in $users) {
            $profilePath = Join-Path -Path $user.FullName -ChildPath 'AppData\Roaming\Microsoft\Windows\Powershell\PSReadline\ConsoleHost_history.txt'
            $profilePathISE = Join-Path -Path $user.FullName -ChildPath 'AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\Windows PowerShell ISE Host_history.txt'
            $result = ""
            If (Test-Path -Path $profilePath) {
                if (Get-content $profilePath){
                    Write-Host -ForegroundColor Green "Powershell history found for user $user in $profilePath"
                    $result += "`nUser: $($user.Name) - $profilePath`n"
                    $result += (Get-Content -Path $profilePath)
                    Write-Host -ForegroundColor Cyan "Deleting Powershell history for $user ..."
                    Clear-Content -Path $profilePath -Force -Verbose
                }
                else{
                    Write-Host -ForegroundColor Yellow "Powershell history found for user $user in $profilePath but file is empty"
                }
            }
            elseif (Test-Path -Path $profilePathISE) {
                if (Get-content $profilePath){
                    Write-Host -ForegroundColor Green "Powershell history found for user $user in $profilePathISE"
                    $result += "`nUser: $($user.Name) - $profilePathISE`n"
                    $result += (Get-Content -Path $profilePathISE)
                    Write-Host -ForegroundColor Cyan "Deleting Powershell history for $user ..."
                    Clear-Content -Path $profilePathISE -Force -Verbose
                }
                else{
                    Write-Host -ForegroundColor Yellow "Powershell history found for user $user in $profilePath but file is empty"
                }
            }
            else{
                Write-Host -ForegroundColor Yellow "No powershell history found for user $user"
            }
            if ($result){
                Add-Content $dumpfile $result -Verbose -Force
            }
        }
        if ($result){
            Write-Host -ForegroundColor Cyan "Saving Powershell history backup in $dumpfile"
            $result | Out-File -FilePath $dumpfile -Encoding UTF8 -Verbose
        }
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to get users list on the system, something went wrong..."
    }
}
catch{
    write-Host -ForegroundColor Red "Error: $_"
}

Stop-Transcript
