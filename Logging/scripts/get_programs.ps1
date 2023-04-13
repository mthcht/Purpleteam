# Function to calculate file hash
function Get-FileHashCustom {
    param (
        [string]$FilePath,
        [string]$HashAlgorithm = "SHA256"
    )

    try {
        $hasher = [System.Security.Cryptography.HashAlgorithm]::Create($HashAlgorithm)
        $fileStream = [System.IO.File]::OpenRead($FilePath)
        $hash = [BitConverter]::ToString($hasher.ComputeHash($fileStream)).Replace("-", "")
        $fileStream.Close()
        $fileStream.Dispose()
        return $hash
    } catch {
        Write-Error "Error: $_"
    }
}

function Format-Date {
    param (
        [DateTime]$Date
    )

    return $Date.ToString("yyyyMMdd")
}

# Function to get the list of executable files within a given directory
function Get-ExecutableFiles {
    param (
        [string]$DirectoryPath
    )

    $executableExtensions = @("*.exe", "*.dll", "*.ps1", "*.bat", "*.vbs", "*.wsf")
    $executables = @()

    foreach ($extension in $executableExtensions) {
        $executables += Get-ChildItem -Path $DirectoryPath -Recurse -Include $extension -ErrorAction SilentlyContinue
    }

    return $executables
}

# Get list of installed programs
$installedApps = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
                 -ErrorAction SilentlyContinue `
                 | Where-Object { $_.DisplayName -ne $null } `
                 | Select-Object DisplayName, DisplayVersion, InstallDate, InstallLocation

# Get list of installed services
$installedServices = Get-WmiObject -Class Win32_Service | Select-Object Name, PathName

# Initialize results array
$results = @()

# Loop through each installed program
foreach ($app in $installedApps) {
    # Get executable path
    $exePath = $app.InstallLocation

    # Calculate hash
    if ($exePath -ne $null) {
        $hash = Get-FileHashCustom -FilePath $exePath
    } else {
        $hash = "N/A"
    }

    $results += @{
        Type          = "Program"
        Name          = $app.DisplayName
        Version       = $app.DisplayVersion
        InstallDate   = $app.InstallDate
        Path          = $exePath
        Hash          = $hash
    }
}

# Loop through each installed service
foreach ($service in $installedServices) {
    Write-Host "$service.name - $service"
    # Get executable path and service command line
    $exePath = $service.PathName.Trim('"') -replace '^(.+)\s+-k.*$', '$1'
    $commandLine = $service.PathName.Trim('"')

    # Calculate hash for the service executable only
    if ($exePath -ne $null) {
        $hash = Get-FileHashCustom -FilePath $exePath
    } else {
        $hash = "N/A"
    }

    $results += @{
        Type            = "Service"
        ServiceName     = $service.Name
        ServicePath     = $exePath
        ServicePathHash = $hash
        CommandLine     = $commandLine
    }
}

# Get list of installed programs from C:\Program Files and C:\Program Files (x86)
$programFilesDirs = @("C:\Program Files", "C:\Program Files (x86)")
$programs = @()

foreach ($dir in $programFilesDirs) {
    if (Test-Path $dir) {
        $programs += Get-ChildItem -Path $dir -Directory -ErrorAction SilentlyContinue
    }
}

# Loop through each program directory
foreach ($program in $programs) {
    # Get all executables within the program directory
    $executables = Get-ExecutableFiles -DirectoryPath $program.FullName 

    # Calculate hash for each executable
    foreach ($executable in $executables) {
        $hash = Get-FileHashCustom -FilePath $executable.FullName
        $formattedDate = Format-Date -Date $executable.CreationTime
        $timestamp = [int64]($executable.CreationTime.ToUniversalTime() - [DateTime]::new(1970, 1, 1)).TotalMilliseconds

        $results += @{
            Type              = "File"
            ProgramFolder     = $program.Name
            FilePath          = $executable.FullName
            FileHash          = $hash
            CreationTime      = $formattedDate
            CreationTimestamp = "$timestamp"
        }
    }

}


$securelogpath = "fixme"
$jsonResults = $results | ConvertTo-Json
$currentdate = (Get-Date).ToString("yyyyMMdd")
$hostname = (Get-WmiObject -Class Win32_ComputerSystem).Name
Set-Content -Path "$securelogpath\inventory_$($hostname)_$currentdate.json" -Value $jsonResults
