<#
    T1497 - Virtualization/Sandbox Evasion
    T1497.001 - Virtualization/Sandbox Evasion: System Checks
    T1588.002 - Obtain Capabilities: Tool
    Script downloads latest release of pafish from github and executes it to detect virtual machine.
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

if([System.IntPtr]::Size -eq 4){
    $pafishexe = "pafish.exe"
}
elseif([System.IntPtr]::Size -eq 8){
    $pafishexe = "pafish64.exe"
}
else{
    Write-Host -ForegroundColor Yellow "Warning: OS architecture could not be detected, downloading x32 version of pafish..."
    $pafishexe = "pafish.exe"
}

Write-Host -ForegroundColor Cyan "Downlaoding latest release of pafish..."
$tag = (Invoke-WebRequest "https://api.github.com/repos/a0rtega/pafish/releases" -UseBasicParsing -Verbose | ConvertFrom-Json)[0].tag_name
$url = "https://github.com/a0rtega/pafish/releases/download/$tag/$pafishexe"
$outfile = "$env:tmp\pafish.exe"

try {
    Invoke-WebRequest $url -OutFile $outfile -Verbose
    if (Test-Path $outfile){
        Write-Host -ForegroundColor Green "Success: pafish downloaded to $outfile"
        Write-Host -ForegroundColor Cyan "Executing pafish... wating 25 seconds for results"
        Start-Process -FilePath $outfile -Verbose 
        Start-Sleep -Seconds 25 -Verbose
        $result = Get-Content "$(get-location)\pafish.log" | Select-String "\[pafish\] End"
        if($result){
            Write-Host -ForegroundColor Green "Success: pafish executed succesfully, results are saved in $(get-location)\pafish.log"
        }
        else{
            Write-Host -ForegroundColor Red "Error: Failed to execute pafish correctly, check $(get-location)\pafish.log for more details"
        }
        Stop-Process -Name pafish -Verbose -Force
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download pafish, $outfile not found."
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
