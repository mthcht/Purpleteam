# T1584.002 - Compromise Infrastructure: DNS Server
# This script will change the DNS settings to use Google's DNS servers or a custom DNS server. 
# Malware can act as a DHCP server and provide adversary-owned DNS servers to the victimized computers

param($DNSServers)

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
}
Write-Host "DNS changed successfully!"
