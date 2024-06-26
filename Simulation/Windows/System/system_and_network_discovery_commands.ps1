<#
    T1046 - Network Service Discovery
    T1057 - Process Discovery
    T1135 - Network Share Discovery
    T1201 - Password Policy Discovery
    T1120 - Peripheral Device Discovery
    T1069 - Permission Groups Discovery
    T1615 - Group Policy Discovery
    T1518.001 - Software Discovery: Security Software Discovery
    T1082 - System Information Discovery
    T1049 - System Network Connections Discovery
    T1033 - System Owner/User Discovery
    T1007 - System Service Discovery
    Multiple system/network discovery commands exections
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

function exec_commands(){
    param (
        [Parameter(Mandatory=$true)]
        [array]$commands
    )

    foreach ($command in $commands){
        Write-Host -ForegroundColor Cyan "[Info] Executing command: $command"
        "`n ---------- Executing command $command ----------`n" >> $dumpfile
        Invoke-Expression $command -Verbose >> $dumpfile
    }
}

try {
    $dumpfile = "$env:tmp\commands_results.txt"
    $commands = @('cmd.exe /c "ipconfig /all"','cmd.exe /c "route PRINT"','powershell.exe "driverquery.exe /v /fo csv | ConvertFrom-CSV | Select-Object 'Display Name', 'Start Mode', Path"','cmd.exe /c "wmic qfe get Caption,Description,HotFixID,InstalledOn"','cmd.exe /c "netstat -ano"','cmd.exe /c "quser"','cmd.exe /c "qwinsta.exe"','cmd.exe /c "hostname"','cmd.exe /c "wmic useraccount get /ALL"','cmd.exe /c "systeminfo"','cmd.exe /c "tracert 8.8.8.8"','cmd.exe /c "getmac"','cmd.exe /c "arp -a"','cmd.exe /c "net share"','cmd.exe /c "net use"','cmd.exe /c "fsutil fsinfo drives"','cmd.exe /c "net view"','cmd.exe /c "gpresult /R /Z"','cmd.exe /c "net accounts"','cmd.exe /c "net group"','cmd.exe /c "WMIC /Node:localhost /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get displayName /Format:List"','powershell.exe "Get-CimInstance -Namespace root/securityCenter2 –classname antivirusproduct"','cmd.exe /c"netsh firewall show state"','cmd.exe /c "schtasks /query /fo LIST /v"','cmd.exe /c "netsh advfirewall firewall show rule name=all dir=out type=dynamic"','cmd.exe /c "ver"','cmd.exe /c "vssadmin list shadows"','powershell.exe "Get-ComputerInfo"',' cmd.exe /c "nbtstat -s"','cmd.exe /c "nbtstat -n"','cmd.exe /c "net config workstation"','cmd.exe /c "netsh wlan show profiles"','powershell.exe "Get-CimInstance -ClassName Win32_Service"','powershell.exe "Get-Process -IncludeUserName | Format-Table -AutoSize"','powershell.exe "Get-CimInstance -ClassName Win32_Share"','powershell.exe "Get-NetNeighbor"','powershell.exe "Get-NetRoute"','powershell.exe "Get-CimInstance -Class Win32_SerialPort"','powershell.exe "Get-CimInstance -ClassName Win32_LoggedOnUser"','powershell.exe "Get-LocalGroupMember -Group Administrators"','cmd.exe /c "net session"','cmd.exe /c "sc query"','cmd.exe /c "tasklist /SVC"','cmd.exe /c "net users"',"whoami /all",'cmd.exe /c "sc query"','cmd.exe /c "query user"','cmd.exe /c "net start"')    exec_commands($commands)
    if (Test-Path $dumpfile){
        Write-Host -ForegroundColor Green "[Success] Results of the commands executed are now saved in $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "[Error] Failed to save results in $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
