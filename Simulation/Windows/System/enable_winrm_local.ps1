# T1021.006 - Remote Services: Windows Remote Management
# This script will enable WinRM (Remote PS) on the local machine.

# Enable WinRM 
Enable-PSRemoting -Force

# Start WinRM Service
Start-Service winrm

# Configure WinRM Listener
winrm quickconfig -q

# Set WinRM Trusted Hosts
$ip = '*'
Set-Item wsman:\localhost\client\trustedhosts $ip -Force

# Configure WinRM Listener to allow Basic Authentication
Set-Item WSMan:\localhost\Service\Auth\Basic $true

# Configure WinRM Listener to allow unencrypted traffic
Set-Item WSMan:\localhost\Service\AllowUnencrypted $true

# Restart WinRM Service
Restart-Service winrm
