<# 
   T1046 - Network Service Discovery
   T1595.001 - Active Scanning: Scanning IP Blocks
   Simple powershell script to make a port scan or a subnet scan 
#>


function scan-tcp {
  # define the parameters 
  param($hostname,$port_numbers)
  # if no ports are passed in, output the usage and return 
  if (!$port_numbers) {
    Write-Host "usage: scan-tcp <host|hosts> <port|ports>"
    Write-Host "       scan-tcp 192.168.1.2 445"
    Write-Host "       scan-tcp 10.0.0.1 137"
    Write-Host "       scan-tcp 10.0.0.1 (135,137,445)"
    Write-Host "       scan-tcp (gc .\ip_list.txt) 137"
    Write-Host "       scan-tcp (gc .\ip_list.txt) (135,137,445)"
    Write-Host "       scan-tcp ('192.168.142.132','localhost') ('8000','5050','445')"
    Write-Host "       0..255 | foreach { scan-tcp 10.0.0.$_ 137 }"
    Write-Host "       0..255 | foreach { scan-tcp 10.0.0.$_ (135,137,445) }"
    return
  }
  $output_file = ".\scan-tcp_result.txt"
  # loop through the ports
  foreach($po in [array]$port_numbers) {
   # loop through the hosts
   foreach($ho in [array]$hostname) {
    # check if the scan result already exists
    $found_result = (gc $output_file -EA SilentlyContinue | select-string "^$ho,tcp,$po,")
    if ($found_result) {
      # if it does, output the result and continue to the next port 
      gc $output_file | select-string "^$ho,tcp,$po,"
      continue
    }
    # initialize the message for outputting to the file 
    $message = "$ho,tcp,$po,"
    try {
      #  create a new tcp client 
      $tcp_client = new-Object system.Net.Sockets.TcpClient
      # begin connecting to the host and port
      $connection = $tcp_client.BeginConnect($ho,$po,$null,$null)
       # wait one second to see if the connection is successful 
      $was_successful = $connection.AsyncWaitHandle.WaitOne(1000,$false)
      $result = "Closed"
      # if the connection was successful 
      if ($was_successful) {
        # end the connection 
        $null = $tcp_client.EndConnect($connection)
        # set the result to open 
        $result = "Open"
      }
      $tcp_client.Close();
    } catch {
      $result = "Error"
    }
    # append the result to the message 
    $message += $result
    Write-Host "$message"
    echo $message >>$output_file
   }
  }
}

#scan-tcp ('192.168.142.132','localhost') ('8000','5050','445')
