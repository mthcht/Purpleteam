<#
    T1070.004 -  Indicator Removal: File Deletion 
    T1070.009 -  Indicator Removal: Clear Persistence 
    This script will remove the Amcache.hve file(s) from the system root directory.
    Impact: The execution of this command will cause the Amcache.hve file to be deleted, resulting in a loss of forensically relevant data
    which could have been used to identify software and programs that have been run on the system.
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

$backupPath = "$env:temp\"

try{
    Copy-Item -Path "$env:SystemRoot\AppCompat\Programs\Amcache.hve*" -Destination $backupPath -Force -Verbose
    Remove-Item -Recurse -Force -Verbose -ErrorAction SilentlyContinue -Path "$env:SystemRoot\AppCompat\Programs\Amcache.hve*" 
}
catch{
    Write-Host -ForegroundColor Red "[Error] Exception: _$"
}

if (Test-Path "$env:SystemRoot\AppCompat\Programs\Amcache.hve*"){
    Write-Host -ForegroundColor Red "[Error] Amcache.hve file was not removed"
}
else{
    Write-Host -ForegroundColor Green "[Success] Amcache file(s) removed successfully"
}

Stop-Transcript -Verbose
