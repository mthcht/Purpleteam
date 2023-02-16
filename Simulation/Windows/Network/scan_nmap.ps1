<#
    T1046 - Network Service Discovery
    T1595.001 - Active Scanning: Scanning IP Blocks
    T1135 - Network Share Discovery
    T1595.002 - Active Scanning: Vulnerability Scanning
    Multiple network scans with nmap 
#>

param (
    [Parameter(Mandatory=$false)]
    [array]$dest,
    [Parameter(Mandatory=$false)]
    [switch]$download
)

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

$nmapoutput = "$env:tmp\nmapoutput.txt"

function exec_commands(){
    param (
        [Parameter(Mandatory=$true)]
        [array]$commands
    )

    foreach ($command in $commands){
        Write-Host -ForegroundColor Cyan "[Info] Executing nmap command: $command"
        "`n ---------- Executing command $command ----------`n" >> $nmapoutput
        Invoke-Expression $command -Verbose -ErrorAction SilentlyContinue
    }
}

try{
    if ($download){
        $urldist = "https://nmap.org/dist"
        $distpage = "$env:tmp\nmapdistpage"
        $nmap = "$env:tmp\nmap.exe"
        Write-Host -ForegroundColor Cyan "[Info] Downloading nmap from $urldist"
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $urldist -OutFile $distpage -UserAgent 'purpleteam' -Verbose
        if (Test-Path $distpage){
            Write-Host -ForegroundColor Green "[Success] Nmap distribution page found at $urldist"
            $webcontentfiltered = @()
            foreach ($line in $(Get-Content $distpage -Verbose -Force)){
                if ($line -like "*lastmod*"){
                    if ($line -like "*.exe*"){
                        $webcontentfiltered += $line
                    }
                }
            }
            $FileName = (Select-String -InputObject $webcontentfiltered[0] -Pattern '<a href="(.*)">(.*)</a></td>').Matches.Groups[1].Value
            $urlexe = "$urldist/$FileName"
            Write-Host -ForegroundColor Cyan "[Info] Downloading nmap from $urlexe"
            Invoke-WebRequest -Uri $urlexe -OutFile $nmap -UserAgent 'purpleteam' -Verbose 
            if (Test-Path $nmap){
                Write-Host -ForegroundColor Green "[Success] Nmap downloaded successfully"
                Write-Host -ForegroundColor Cyan "[Info] Installing nmap... please proceed to manual installation`n(if you want a silent install check nmap OEM version (cmdline arguments with silent option) or chocolatey package nmap (automatic but not silent))"
                Invoke-Expression $nmap -Verbose
                Write-Host -ForegroundColor Green "[Success] exiting script..."
                exit 1
            }
            else{
                Write-Host -ForegroundColor Red "[Error] Failed to download Nmap from $urlexe"
            }
        }
        else{
            Write-Host -ForegroundColor Red "[Error] Failed to find Nmap distribution page $distpage"
        }
    }
    else{
        Write-Host -ForegroundColor Cyan "[Info] Checking if nmap is installed..."
        $nmap = nmap
        if ($nmap){
            Write-Host -ForegroundColor Green "[Success] Nmap is installed"
            if (-not $dest){
                Write-Host -ForegroundColor Yellow "[Warning] No destination specified, scanning detected local network"
                $addresses = [Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | ForEach-Object {$_.GetIPProperties().UnicastAddresses} | Where-Object {$_.Address.AddressFamily -eq 'InterNetwork'}
                $dest = (($addresses | Select-Object Address | ForEach-Object { $IP = $_.Address.ToString(); $IP.Substring(0, $IP.LastIndexOf('.') + 1) + '0/24' }) -replace "^.*(127\.|169\.254\.).*$", "") | Where-Object {$_ -match "^[0-9]"}
                if ($dest){
                    Write-Host -ForegroundColor Green "[Success] Local IP address range detected, scanning local network(s): $dest, executing fast nmap scans on target(s)..."
                    foreach ($dest_range in $dest){
                        Write-Host -ForegroundColor Cyan "[Info] Fast scans on target(s) $dest_range..."
                        $nmap_commands = @("nmap -sn -d $dest_range --max-rtt-timeout 1s --min-parallelism 100 --append-output -oN $nmapoutput","nmap -d --top-ports 15 --max-rtt-timeout 1s --min-parallelism 100 $dest_range --append-output -oN $nmapoutput","nmap -d -p 445 -script='smb-vuln-ms17-010.nse' --max-rtt-timeout 1s --min-parallelism 100  $dest_range --append-output -oN $nmapoutput")
                        exec_commands -commands $nmap_commands
                    }
                }
                else{
                    Write-Host -ForegroundColor Red "[Error] Failed to detect local networks IP address range, exiting script..."
                    exit 1
                }
            }
            else{
                foreach ($dest_range in $dest){
                    Write-Host -ForegroundColor Cyan "[Info] Scanning destination(s) given as argument: $dest_range, executing full nmap scans on target(s). this can take a long time, please be patient..."
                    $nmap_commands = @("nmap -d -sV -p 389 --script ldap-search $dest_range --max-rtt-timeout 1s --min-parallelism 100 --append-output -oN $nmapoutput","nmap -d -A -T4 -sC -sV -p- $dest_range --max-rtt-timeout 1s --min-parallelism 100 --append-output -oN $nmapoutput","nmap -d -sV -sU $dest_range --max-rtt-timeout 1s --min-parallelism 100 --append-output -oN $nmapoutput","nmap -d -A -T4 -sC -sV --script vuln $dest_range --max-rtt-timeout 1s --min-parallelism 100 --append-output -oN $nmapoutput","nmap -d -A -T4 -p- -sS -sV -oN initial --script discovery $dest_range --max-rtt-timeout 1s --min-parallelism 100 --append-output -oN $nmapoutput")
                    exec_commands -commands $nmap_commands
                }
            }
    
            if (Test-Path $nmapoutput){
                Write-Host -ForegroundColor Green "[Success] Nmap output saved in $nmapoutput"
            }
            else{
                Write-Host -ForegroundColor Red "[Error] Nmap output not found, something went wrong..."
            }    
        }
        else{
            Write-Host -ForegroundColor Red "[Error] Nmap not found, exiting script, use the argument -download with this script to download nmap and proceed to manual installation..."
            exit 1
        }
    }
}
catch{
    Write-Host -ForegroundColor Red "[Error] $_"
}

Stop-Transcript -Verbose 
