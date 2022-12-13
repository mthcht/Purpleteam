# T1070.001 - Indicator Removal: Clear Windows Event Logs

$evtLogs = (Get-EventLog -List).Log

$j = 0
foreach($i in $evtLogs)
{
 Write-Host "$j : $i" 
 $j++
}

Write-Host "Which eventlogs do you want to clear? (select a number)"
$evtLogIndexes = Read-Host
$evtLogNames = $evtLogs[$evtLogIndexes]
Write-Host "Are you sure you want to clear $evtLogNames ? (y/n)"
$confirm = Read-Host

If ($confirm -eq "y") 
{
    Clear-EventLog -LogName $evtLogNames
    Write-Host "Event logs $evtLogNames have been cleared!"
} Else {
    Write-Host "Event logs $evtLogNames have not been cleared!"
}
