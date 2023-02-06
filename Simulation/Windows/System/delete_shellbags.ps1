<#
    T1070.009 - Indicator Removal: Clear Persistence
    T1112 - Modify Registry
    T0872 - Indicator Removal on Host
    Anti forensic script to remove shellbags values from the registry
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

$shellbagntuser = "HKCU:\Software\Microsoft\Windows\Shell"
$shellbagusrclass = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell"
$shellbagold = @("HKCU:\Software\Microsoft\Windows\ShellNoRoam","HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\ShellNoRoam","HKCU:\Software\Classes\Wow6432Node\Local Settings\Software\Microsoft\Windows\Shell")

try {
    if (Test-Path $shellbagntuser){
        Write-Host -ForegroundColor Cyan "Deleting shellbags from $shellbagntuser..."
        Remove-Item -Path "$shellbagntuser\BagMRU" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
        Remove-Item -Path "$shellbagntuser\Bags" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
        if ((test-path $shellbagntuser\BagMRU) -or (test-path $shellbagntuser\Bags)){
            Write-Host -ForegroundColor Red "Error: Failed to delete shellbags from $shellbagntuser"
        }
        else{
            Write-Host -ForegroundColor Green "Success: Deleted shellbags from $shellbagntuser"
        }
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to find shellbags in $shellbagntuser"
    }
    if (Test-Path $shellbagusrclass){
        Write-Host -ForegroundColor Cyan "Deleting shellbags from $shellbagusrclass..."
        Remove-Item -Path "$shellbagusrclass\BagMRU" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
        Remove-Item -Path "$shellbagusrclass\Bags" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
        if ((test-path $shellbagusrclass\BagMRU) -or (test-path $shellbagusrclass\Bags)){
            Write-Host -ForegroundColor Red "Error: Failed to delete shellbags from $shellbagusrclass"
        }
        else{
            Write-Host -ForegroundColor Green "Success: Deleted shellbags from $shellbagusrclass"
        }
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to find shellbags in $shellbagusrclass"
    }

    Write-Host -ForegroundColor Cyan "Deleting pther possible shellbags location..."
    foreach ($shellbag in $shellbagold){
        if (Test-Path $shellbag){
            Write-Host -ForegroundColor Cyan "Deleting shellbags from $shellbag..."
            Remove-Item -Path "$shellbag\BagMRU" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
            Remove-Item -Path "$shellbag\Bags" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
            if ((test-path $shellbag\BagMRU) -or (test-path $shellbag\Bags)){
                Write-Host -ForegroundColor Red "Error: Failed to delete shellbags from $shellbag"
            }
            else{
                Write-Host -ForegroundColor Green "Success: Deleted shellbags from $shellbag"
            }
        }
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
