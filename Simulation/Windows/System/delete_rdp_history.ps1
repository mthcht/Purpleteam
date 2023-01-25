<# 
    T1070.007 - Indicator Removal: Clear Network Connection History and Configurations
    This script will delete the registry entries and files related to recent RDP connections.
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

try{
    #Get the current user
    $User = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

    #Delete registry entries
    Remove-Item -Path "Registry::HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Default" -Recurse
    Remove-Item -Path "Registry::HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Servers" -Recurse

    #Delete files
    Remove-Item -Path "C:\Users\$User\Documents\Default.rdp" -Force
    Remove-Item -Path "C:\Users\$User\AppData\Local\Microsoft\TerminalServer Client\Cache\*" -Force
}
catch{
    Write-Host -ForegroundColor Red "Error: $_"
}

Stop-Transcript
