<#
    T1070.004 - Indicator Removal: File Deletion
    T1112 - Modify Registry
    Delete Most Recent Used items in registry
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

try {
    $reglist = @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU","HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths","HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FindComputerMRU","HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Doc Find Spec MRU","HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\PrnPortsMRU","HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StreamMRU","HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU")
    foreach ($regkey in $reglist){
        if (Test-Path -Path $regkey){
            Write-Host -ForegroundColor Cyan "[Info] Registry key found, deleting $regkey ..."
            Remove-Item -Path $regkey -Recurse -Force -Verbose
            if (Test-Path -Path $regkey){
                Write-Host -ForegroundColor Red "[Error] Failed to delete $regkey"
            }
            else{
                Write-Host -ForegroundColor Green "[Success] Registry key entries deleted: $regkey"
            }
        }
    }
}
catch {
    Write-Host -ForegroundColor Red "`n[Error] Exception: $_"
}

Stop-Transcript -Verbose
