<#
    T1070.001 - Indicator Removal: Clear Windows Event Logs
    Clear All Windows EventLogs (-ask for basic log selection)
#>

param (
    [Parameter(Mandatory=$false)]
    [switch]$ask
)

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

try {
    if ($ask -eq $true){
        $evtLogs = (Get-EventLog -List).Log
        Write-Host -ForegroundColor Cyan "Input Mode activated with -ask, asking user for basic log selections..."
        $j = 0
        foreach($i in $evtLogs){
            Write-Host "$j : $i" 
            $j++
        }
        Write-Host "Which eventlogs do you want to clear? (select a number)"
        $evtLogIndexes = Read-Host
        $evtLogNames = $evtLogs[$evtLogIndexes]
        Write-Host "Are you sure you want to clear $evtLogNames ? (y/n)"
        $confirm = Read-Host

        if ($confirm -eq "y"){
            Clear-EventLog -LogName $evtLogNames -Verbose
            Write-Host "Event logs $evtLogNames have been cleared!"
        }
        else {
            Write-Host "Event logs $evtLogNames have not been cleared!"
        }
    }
    else {
        $evtLogs = Get-WinEvent -ListLog * -Force -Verbose
        foreach($event in $evtLogs){
            Write-Host -ForegroundColor Cyan "Clearing log $($event.LogName)..."
            wevtutil cl $event.LogName
        }
    }
}
catch {
    Write-Host -ForegroundColor Red "Error: $_"
}


Stop-Transcript
