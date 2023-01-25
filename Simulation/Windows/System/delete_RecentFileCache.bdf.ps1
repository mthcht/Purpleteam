<#
    T1070.004 -  Indicator Removal: File Deletion 
    T1070.009 -  Indicator Removal: Clear Persistence 
    Simple script anti forensic: Remove RecentFileCache.bcf
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

try{
    $Drives = Get-WMIObject Win32_LogicalDisk | Select-Object -Property DriveType, DeviceID
    foreach($Drive in $Drives)
    {   
        if($Drive.DriveType -eq 3){
            $recentfilespath = [string]$Drive.DeviceID + "\Windows\AppCompat\Programs\RecentFileCache.bcf"
            If (Test-Path $recentfilespath) {
                Remove-Item -Path $recentfilespath -Force
                If (!(Test-Path $recentfilespath)) {
                    Write-Host -ForegroundColor Green "Sucess: RecentFileCache.bcf was deleted successfully"
                }
                Else {
                    Write-Host "Unable to delete $recentfilespath"
                }
            }
            Else {
                Write-Host -ForegroundColor Yellow "$recentfilespath does not exist"
            }
            
        }
    }
}
catch{
    Write-Host -ForegroundColor Red "Error: $_"
}

Stop-Transcript
