<#
    T1588.002 - Obtain Capabilities: Tool
    T1204.002 - User Execution: Malicious File
    Download EICAR test files from project https://github.com/mthcht/Purpleteam/tree/main/Simulation/Windows/_bin/eicar and check automatic deletion by Security products
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

$url = "https://github.com/mthcht/Purpleteam/tree/main/Simulation/Windows/_bin/eicar" 
$files = Invoke-WebRequest -Uri $url | Select-Object -ExpandProperty Links | Where-Object {$_.InnerText -match ".*(?:_\d+)*\.\w+"} | Select-Object -ExpandProperty InnerText
if ($files){
    Write-Host -ForegroundColor Green "Success: Found $($files.count) files in $url"
    foreach ($file in $files){
        if (-not ($file -like "*.md")){
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/eicar/$file" -OutFile "$env:tmp\$file" -Verbose -UserAgent "EICAR-Test-File"
            if (Test-Path "$env:tmp\$file"){
                Write-Host -ForegroundColor Green "Success: $file downloaded to $env:tmp\$file"
            }
            else{
                Write-Host -ForegroundColor Yellow "Failed to download $file to $env:tmp\$file"
            }
        }
    }
    Write-Host -ForegroundColor Cyan "Waiting for 10 seconds for AV detections..."
    Start-Sleep 10
    foreach ($file in $files){
        if (-not ($file -like "*.md")){
            if(Test-Path "$env:tmp\$file"){
                Write-Host -ForegroundColor Red "Error: $file is still in $env:tmp\$file and not deleted"
            }
            else{
                Write-Host -ForegroundColor Yellow "$file not found in $env:tmp\$file, it may have been deleted by AV solution"
            }
        }
    }    
}
else{
    Write-Host -ForegroundColor Red "Error: No files found in $url"
}


Stop-Transcript
