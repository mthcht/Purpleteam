# T1027.009 - Obfuscated Files or Information: Embedded Payloads

# Get the current directory location
$currentLocation = Get-Location

# Create benign binary
$binaryFilePath = "$currentLocation\Binary.exe"
$binaryContent = [System.Text.Encoding]::Unicode.GetBytes("Purpleteam: This is a benign binary ")
[System.IO.File]::WriteAllBytes($binaryFilePath, $binaryContent)

# Create payload
$payloadFilePath = "$currentLocation\Payload.exe"
$payloadContent = [System.Text.Encoding]::Unicode.GetBytes("Purpleteam: This is a fake payload")
[System.IO.File]::WriteAllBytes($payloadFilePath, $payloadContent)

# Combine benign binary and payload
$combinedFilePath = "$currentLocation\Combined.exe"
$combinedContent = [System.Text.Encoding]::Unicode.GetBytes($binaryContent + $payloadContent)
[System.IO.File]::WriteAllBytes($combinedFilePath, $combinedContent)
