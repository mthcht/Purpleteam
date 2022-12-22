<# 
   T1070.009 - Indicator Removal: Clear Persistence
   T1547.001 - Boot or Logon Autostart Execution: Registry Run Keys / Startup Folder
#>

$currentUser = [Environment]::UserName

# Create exe files
$FileName = "Purpleteam.exe"
$FilePath = "C:\Windows\Temp\$FileName"
$FilePath2 = "C:\Users\$currentUser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\$FileName"
New-Item -Path $FilePath -ItemType File -Force
New-Item -Path $FilePath2 -ItemType File -Force

# Add the executable to registry
$regKey = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
$regKey2 = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$regName = 'Purpleteam'
Set-ItemProperty -Path $regKey -Name $regName -Value $FilePath
Set-ItemProperty -Path $regKey2 -Name $regName -Value $FilePath2


# Remove the executable from registry
Remove-ItemProperty -Path $regKey -Name $regName
Remove-ItemProperty -Path $regKey2 -Name $regName

# Delete exe files
Remove-Item -Path $FilePath -Force
Remove-Item -Path $FilePath2 -Force
