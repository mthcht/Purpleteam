### Log investigation

#### Get last 5 minutes generated logs on system:

`$t=(Get-Date).AddMinutes(-5);Get-WinEvent -ListLog * | %{Get-WinEvent -FilterHashtable @{LogName=$_.LogName; StartTime=$t;} -ErrorAction Ignore | Format-Table -AutoSize -Wrap} | Out-File last5minuteslogs.txt`

#### Search for a specific string in all recent generated logs:

`$t=(Get-Date).AddMinutes(-5);Get-WinEvent -ListLog * | %{Get-WinEvent -FilterHashtable @{LogName=$_.LogName; StartTime=$t;} -ErrorAction Ignore  | Where-Object {$_.Message -like "*FIXME*"} | Format-Table -AutoSize -Wrap}` 

#### Get recently created files

`Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.LastWriteTime -gt (Get-Date).AddMinutes(-5)} | foreach {Write-Host $_.FullName - $_.LastWriteTime}`
