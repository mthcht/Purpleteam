### Log investigation

#### Get last 5 minutes generated logs on system:

`$t=(Get-Date).AddMinutes(-5);Get-WinEvent -ListLog * | %{Get-WinEvent -FilterHashtable @{LogName=$_.LogName; StartTime=$t;} -ErrorAction Ignore | Format-Table -AutoSize -Wrap} | Out-File last5minuteslogs.txt`

#### Search for a specific string in all recent generated logs:

`$t=(Get-Date).AddMinutes(-5);Get-WinEvent -ListLog * | %{Get-WinEvent -FilterHashtable @{LogName=$_.LogName; StartTime=$t;} -ErrorAction Ignore  | Where-Object {$_.Message -like "*FIXME*"} | Format-Table -AutoSize -Wrap}` 

####  Get last 5 minutes modified files on system:

`$t = (Get-Date).AddMinutes(-5);Get-ChildItem -Path "$env:HOMEDRIVE\" -Recurse -Force -ErrorAction Ignore | Where-Object { $_.LastWriteTime -gt $t } | Format-Table -AutoSize -Wrap | Out-File last5minutesfiles.txt`

`Get-ChildItem -Path "$env:HOMEDRIVE\" -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.LastWriteTime -gt (Get-Date).AddMinutes(-5)} | foreach {Write-Host $_.FullName - $_.LastWriteTime}`

Note:  -Attributes with Get-ChildItem can help you find more files

add "-Attributes Hidden" for the last modified hidden files/dir for example...

#### Get Basic Sysmon Event ID 1 Informations ParentImage - Image - CommandLine in powershell
```
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; ID=1} | ForEach-Object {
    $eventXml = [xml]$_.ToXml()
    $process = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'Image' }
    $parentProcess = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'ParentImage' }
    $commandLine = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'CommandLine' }
    $timeCreated = $_.TimeCreated

    [PSCustomObject]@{
        TimeCreated = $timeCreated
        Process = $process.'#text'
        ParentProcess = $parentProcess.'#text'
        CommandLine = $commandLine.'#text'
    }
} | Sort-Object TimeCreated
```


### Others

#### Get loggedin user

`(Get-ItemProperty "REGISTRY::HKEY_USERS\S-1-5-21-*\Volatile Environment").UserName`

#### Get RecycleBins content
`Get-ChildItem -Path "$env:HOMEDRIVE\$Recycle.Bin" -Force -Recurse`
