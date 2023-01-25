<#
    T1222 - File and Directory Permissions Modification 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

Function ghelp{
    Write-Host 
"This script creates a shortcut to a file or application and set permissions to it.
The first argument is the source of the shortcut, and the second argument is the target of the shortcut.
The permission is set to Everyone,FullControl"
    Write-Host ""
    Write-Host "Usage: create-shortcut.ps1 <Link Source> <Link Target>"
    Write-Host ""
    Write-Host "Example: create-shortcut.ps1 C:\users\shortcut.lnk \\remote_share\secrets.kdbx"
}

if ($args[0] -eq $null){
    ghelp
    break
}


$LinkSource = $args[0]
$LinkTarget = $args[1]

$LinkPermissions = "Everyone,FullControl"
$link = New-Object -ComObject Wscript.Shell

$shortcut = $link.CreateShortcut($LinkSource)
$shortcut.TargetPath = $LinkTarget
$shortcut.Save()

$acl = Get-Acl -Path $LinkSource
$permission = $LinkPermissions.Split(',')
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($permission[0],$permission[1],"Allow")
$acl.SetAccessRule($accessRule)
$acl | Set-Acl -Path $LinkSource

Stop-Transcript
