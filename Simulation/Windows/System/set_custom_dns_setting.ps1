<#
    T1584.002 - Compromise Infrastructure: DNS Server
    This script will change the DNS settings to use Google's DNS servers or a custom DNS server. 
    Malware can act as a DHCP server and provide adversary-owned DNS servers to the victimized computers
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

param(
    [Parameter(Mandatory=$false)]
    [string]$DNSServers
)

if ($DNSServers -eq $null) {
    $DNSServers = "8.8.8.8","8.8.4.4"
}

#Get the network adapters on the computer
$NetworkAdapters = Get-NetAdapter 

#Loop through the network adapters
foreach ($Adapter in $NetworkAdapters)
{
    #Set the DNS servers for the adapter
    Set-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex -ServerAddresses $DNSServers
    if($? -eq $True){   
        Write-Host -ForegroundColor Green "Success: DNS changed to $DNSServers successfully for" $Adapter.Name
    }
    else{
        Write-Host -ForegroundColor Red "Error:DNS cannot be changed to $DNSServers for" $Adapter.Name
    }
}


Stop-Transcript
