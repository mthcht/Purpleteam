<#
    T1562.010 - Impair Defenses: Downgrade Attack
    T1059.001 - Command and Scripting Interpreter: PowerShell
    This script is used to detect if powershell version 2 is installed on the machine and can be exploited by malicious actors
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

$pwsh_commands = @("Start-Job {Get-Process} -PSVersion 2.0","powerShell -Version 2","powershell -v 2 -c 'Get-Process'","powerShell -v 2","Set-PSVersion -Version 2","$PSVersionTable.PSVersion = 2","$PSVersionTable['PSVersion'] = '2.0',Set-Item ws.PSVersion 2","pwsh -v 2","pwsh -v 2","pwsh -version 2")

function execute_command($command){
    $result = Invoke-Expression $command -ErrorAction SilentlyContinue
    if ($result){
        Write-Host -ForegroundColor Yellow "[Warning] Command executed successfully : command: $command`nresult: $result`nPowershell Version 2 is installed on the machine and can be exploited"
    }
    else{
        Write-Host -ForegroundColor Cyan "[Info] Command failed to execute: $command"
    }
}

foreach ($command in $pwsh_commands){
    Write-Host -ForegroundColor Cyan "[Info] Executing command: $command"
    execute_command($command)
}

Stop-Transcript -Verbose
