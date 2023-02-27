### Log investigation

#### Get last 5 minutes generated logs on system:

`$t=(Get-Date).AddMinutes(-5);Get-WinEvent -ListLog * | %{Get-WinEvent -FilterHashtable @{LogName=$_.LogName; StartTime=$t;} -ErrorAction Ignore | Format-Table -AutoSize -Wrap} | Out-File last5minuteslogs.txt`

#### Search for a specific string in all recent generated logs:

`$t=(Get-Date).AddMinutes(-5);Get-WinEvent -ListLog * | %{Get-WinEvent -FilterHashtable @{LogName=$_.LogName; StartTime=$t;} -ErrorAction Ignore  | Where-Object {$_.Message -like "*FIXME*"} | Format-Table -AutoSize -Wrap}` 

####  Get last 5 minutes modified files on system:

`$t = (Get-Date).AddMinutes(-5);Get-ChildItem -Path "$env:HOMEDRIVE\" -Recurse -Force -ErrorAction Ignore | Where-Object { $_.LastWriteTime -gt $t } | Format-Table -AutoSize -Wrap | Out-File last5minutesfiles.txt`

Note:  -Attributes with Get-ChildItem can help you find more files

add "-Attributes Hidden" for the last modified hidden files/dir for example...

### Others

#### Get recently created files

`Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.LastWriteTime -gt (Get-Date).AddMinutes(-5)} | foreach {Write-Host $_.FullName - $_.LastWriteTime}`

#### Get loggedin user

`(Get-ItemProperty "REGISTRY::HKEY_USERS\S-1-5-21-*\Volatile Environment").UserName`

#### Get RecycleBins content
`Get-ChildItem -Path 'C:\$Recycle.Bin' -Force -Recurse`
