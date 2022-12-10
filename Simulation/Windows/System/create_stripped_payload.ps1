# T1027.008 - Obfuscated Files or Information: Stripped Payloads

# Get the current directory location
$currentLocation = Get-Location

# Create payload
$payloadFilePath = "$currentLocation\payload.exe"
$payloadContent = [System.Text.Encoding]::Unicode.GetBytes("Purpleteam: This is a fake payload")
[System.IO.File]::WriteAllBytes($payloadFilePath, $payloadContent)


# Create a stripped version of the payload
$bytes = [System.IO.File]::ReadAllBytes($payloadFilePath)
$stripped_bytes = [System.Array]::CreateInstance([System.Byte], $bytes.Length)
[System.Array]::Copy($bytes, $stripped_bytes, $bytes.Length)

# Strip the strings and symbols
for($i=0; $i -lt $stripped_bytes.Length; $i++){
    if($stripped_bytes[$i] -eq 0x00)
    {
        # Replace any 0x00 bytes with random values
        $stripped_bytes[$i] = [System.Byte](Get-Random -Minimum 0 -Maximum 255)
    }
}

# Output the new payload
$outputPath = "$currentLocation\stripped_payload.exe"
[System.IO.File]::WriteAllBytes($outputPath, $stripped_bytes)
