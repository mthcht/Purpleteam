<#
  T1205 - Traffic Signaling
  T1016 - System Network Configuration Discovery
  Script retrieving mac addresses in ARP table and sending WOL packet to each of them, this is often used by attackers to infect as many workstations as possible ont he network  
  example: Ryuk has used Wake-on-Lan to power on turned off systems for lateral movement (https://attack.mitre.org/software/S0446/) 
#>

#Create an array of MAC addresses
$arpTableDict = @{}

# Adding every usable IP addresses the machine has talked to (seen in the arp table) and add them to the array $arpTableDict 
Get-NetNeighbor | Where-Object { ($_.IPAddress -notlike "*:*") -and ($_.IPAddress -notlike "169.*") -and ($_.LinkLayerAddress -notlike "FF-FF-FF-FF-FF-FF") -and ($_.IPAddress -match "^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.)") } | foreach {
    $arpTableDict.Add($_.IPAddress, $_.LinkLayerAddress)
}

#Loop through the array and attempt to send the Wake-on-Lan packet
foreach($mac in $arpTableDict.Values){
    Write-Host "--- $mac ---"
    try{
        #Create a new packet using the MAC address
        $packet = New-Object byte[](102)
        #Fill the array with 6 bytes of 0xFF
        for($i=0;$i -le 5;$i++)
        {
            $packet[$i] = 255
        }
        #Fill the array with 16 repetitions of the MAC address
        for($i=6;$i -le 101;$i+=6)
        {
            $mac.Split('-') | ForEach-Object { 
                $packet[$i] = [Convert]::ToByte($_,16)
            }
        }
        #Send the packet to the broadcast address
        $Udpclient = New-Object System.Net.Sockets.UdpClient
        $Udpclient.Connect(([System.Net.IPAddress]::Broadcast),9)
        $Udpclient.Send($packet,$packet.length)
        Write-Host "$Udpclient - $packet - $packet.length "
        $Udpclient.Close()
    }
    catch{
        Write-Host -ForegroundColor Red "[failed] Error sending packet to $mac : $_"
    }
}
