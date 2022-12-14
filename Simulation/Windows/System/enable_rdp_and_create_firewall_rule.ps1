# T1021.001 - Remote Services: Remote Desktop Protocol
# T1112 - Modify Registry
# T1543.003 - Create or Modify System Process: Windows Service
# TA0008 - Lateral Movement
# TA0005 - Defense Evasion

#Enable RDP service
if((Get-Service -Name TermService).Status -ne "Running")
{
    Write-Host -ForegroundColor Green "Enabling RDP service"
    Set-Service -Name TermService -StartupType Automatic
    Start-Service -Name TermService
}

#Enable Remote Desktop
if((Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-Name fDenyTSConnections).fDenyTSConnections -eq 1)
{
    Write-Host -ForegroundColor Green "Enabling RDP..."
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0
}

#Enable Firewall Rule
$fwRuleName = "Allow RDP"
if (-not (Get-NetFirewallRule -DisplayName $fwRuleName))
{
    Write-Host -ForegroundColor Green "Enabling Firewall Rule..."
    New-NetFirewallRule -DisplayName $fwRuleName -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow -Enabled True
}

