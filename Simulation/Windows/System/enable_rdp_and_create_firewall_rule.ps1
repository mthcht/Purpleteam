<#
    T1021.001 - Remote Services: Remote Desktop Protocol
    T1112 - Modify Registry
    T1543.003 - Create or Modify System Process: Windows Service
    TA0008 - Lateral Movement
    TA0005 - Defense Evasion
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

try{
    Write-Host -ForegroundColor Cyan "Enabling RDP and starting it if not running..."
    Set-Service -Name TermService -StartupType Automatic -Verbose
    if ((Get-Service -Name TermService).Status -ne "Running"){
        Start-Service -Name TermService -Verbose
        $result = (Get-Service -Name TermService | Select-Object -Property Name, Status, StartType)
        if ($result.Status -eq "Running"){
            Write-Host -ForegroundColor Green "Sucess: RDP service is now running"
        }
        else{
            Write-Host -ForegroundColor Red "Error: RDP service is not running, something went wrong..."
        }
    }
    else{
        Write-Host -ForegroundColor Green "RDP service is already running"
    }
    $result = (Get-Service -Name TermService | Select-Object -Property Name, Status, StartType)
    if ($result.StartType -eq "Automatic"){
        Write-Host -ForegroundColor Green "Success: RDP service is set to start automatically"
    }
    else{
        Write-Host -ForegroundColor Red "Error: RDP service is not set to start automatically, something went wrong..."
    }

    if((Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-Name fDenyTSConnections).fDenyTSConnections -eq 1){
        Write-Host -ForegroundColor Cyan "RDP is disabled in registry, enabling RDP in registry"
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0 -Verbose -Force
        $result = (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-Name fDenyTSConnections).fDenyTSConnections
        if ($result -eq 0){
            Write-Host -ForegroundColor Green "Success: RDP is now enabled in registry"
        }
        else{
            Write-Host -ForegroundColor Red "Error: RDP is not enabled in registry, something went wrong..."
        }
    }

    $fwRuleName = "Allow RDP"
    if (-not (Get-NetFirewallRule -DisplayName $fwRuleName -ErrorAction SilentlyContinue -Verbose)){
        Write-Host -ForegroundColor Cyan "Enabling Firewall Rule to allow RDP..."
        New-NetFirewallRule -DisplayName $fwRuleName -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow -Enabled True
        $result = (Get-NetFirewallRule -DisplayName $fwRuleName -ErrorAction SilentlyContinue -Verbose)
        if ($result.Enabled -eq "True"){
            Write-Host -ForegroundColor Green "Success: Firewall Rule to enable RDP is now enabled"
        }
        else{
            Write-Host -ForegroundColor Red "Error: Failed to enable firewall Rule that allow RDP, something went wrong..."
        }
    }
    else{
        Write-Host -ForegroundColor Green "Success: Firewall Rule to enable RDP already exists"
    }
}
catch{
    Write-Host -ForegroundColor Red "Error: $_"
}
Stop-Transcript
