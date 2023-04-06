# Set up logging
$LogPath = "$env:tmp\SysmonInstaller.log"
$LogStream = [System.IO.StreamWriter]::new($LogPath, $true)

# Check if running as administrator
try {
    $isAdministrator = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdministrator) {
        Write-Warning "Please run this script as an Administrator"
        throw "Not running as an Administrator"
    }
}
catch {
    $LogStream.WriteLine("ERROR: $_")
    $LogStream.Close()
    exit 1
}

# Download Sysmon
try {
    Write-Host "Downloading Sysmon..."
    $url = "https://live.sysinternals.com/sysmon.exe"
    $output = "sysmon.exe"
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
    $LogStream.WriteLine("Sysmon downloaded to $output")
}
catch {
    $LogStream.WriteLine("ERROR: $_")
    $LogStream.Close()
    exit 1
}

# Download Sysmon configuration file
try {
    Write-Host "Downloading Sysmon configuration..."
    $configUrl = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Logging/sysmon_everything.xml" # Replace this URL with the location of your configuration file
    $configOutput = "sysmon_config.xml"
    Invoke-WebRequest -Uri $configUrl -UseBasicParsing -OutFile $configOutput
    $LogStream.WriteLine("Sysmon configuration downloaded to $configOutput")
}
catch {
    $LogStream.WriteLine("ERROR: $_")
    $LogStream.Close()
    exit 1
}

# Install Sysmon
try {
    Write-Host "Installing Sysmon..."
    $installArguments = @("/accepteula", "/i", $configOutput)
    Start-Process -FilePath .\$output -ArgumentList $installArguments -Wait -NoNewWindow
    $LogStream.WriteLine("Sysmon installed with configuration file $configOutput")
}
catch {
    $LogStream.WriteLine("ERROR: $_")
    $LogStream.Close()
    exit 1
}

# Clean up
try {
    Write-Host "Cleaning up..."
    Remove-Item $output
    Remove-Item $configOutput
    $LogStream.WriteLine("Cleaned up temporary files")
}
catch {
    $LogStream.WriteLine("ERROR: $_")
    $LogStream.Close()
    exit 1
}

Write-Host "Sysmon installation completed"
$LogStream.WriteLine("Sysmon installation completed")
$LogStream.Close()
