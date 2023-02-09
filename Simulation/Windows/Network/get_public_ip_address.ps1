<#
    T1590.005 - Gather Victim Network Information: IP Addresses
    Get Public IP address informations on ipinfo.io
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

try{
    Write-Host -ForegroundColor Cyan "Getting Public IP address on ipinfo.io..."
    $myip = Invoke-RestMethod -Uri https://ipinfo.io/json -UseBasicParsing -Method GET -UserAgent "purpleteam" -Verbose
    if ($myip){
        Write-Host -ForegroundColor Green "Success: retrieved public IP address:`n - $($myip.ip)`n$myip"
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to get public IP address on ipinfo.io, check internet connection..."
    }
}
catch{
    Write-Host -ForegroundColor Red "Error: $_"
}

Stop-Transcript
