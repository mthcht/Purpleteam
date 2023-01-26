<#
    T1552.001 - Unsecured Credentials: Credentials In Files
    T1083 - File and Directory Discovery
    Simple script to search for strings inside files in a given directory (equivalent to a grep -rnw "mystring" .)
    Example usage: 
    search for 'password=' in every files in the current directory and save the result in results.txt in the same directory
    - powershell.exe -ep Bypass -File .\search_for_credentials_in_files.ps1 -search 'password=' -path . -out ./results.txt
    Ask for user input and print results in the console
    - powershell.exe -ep Bypass -File .\search_for_credentials_in_files.ps1
    search for 'your password' in every files in the parent directory and print results in the console
    - powershell.exe -ep Bypass -File .\search_for_credentials_in_files.ps1 -search 'your password' -path ../
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$search,
    
    [Parameter(Mandatory=$false)]
    [string]$path,

    [Parameter(Mandatory=$false)]
    [string]$out
)

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

if(!$search){
    $search = Read-Host -Prompt "Enter the search string"
    $path = Read-Host -Prompt "Enter the path"
}

$files = Get-ChildItem $path -Recurse -Include *.txt,*.doc,*.docx,*.xlsx,*.csv,*.ppt,*.pptx,*.pdf,*.rtf,*.log,*.xml,*.xls,*.html,*.htm,*.md,*.ini,*.bat,*.ps1,*.py,*.cmd,*.json,*.msg,*.sh

if($out){
    $files | ForEach-Object {
        $filePath = $_.FullName
        (Select-String -Path $filePath -Pattern $search).LineNumber | Where-Object {
            -not [string]::IsNullOrEmpty($(Get-Content $filePath | Select-String -Pattern $search -Context 0,1))
        } | ForEach-Object {
            $content = "`n`nFound in $filePath -- Line Number: $_ -- Content:`n $(Get-Content $filePath | Select-String -Pattern $search -Context 0,1)"
            Add-Content -Path $out -Value $content
        }
    }
}
else{
    Write-Host "No output file path specified. Results are printed in the console."
    $files | ForEach-Object {
        $filePath = $_.FullName
        (Select-String -Path $filePath -Pattern $search).LineNumber | Where-Object {
            -not [string]::IsNullOrEmpty($(Get-Content $filePath | Select-String -Pattern $search -Context 0,1))
        } | ForEach-Object {
            Write-Host "`n`nFound in $filePath -- Line Number: $_ -- Content:`n $(Get-Content $filePath | Select-String -Pattern $search -Context 0,1)"
        }
    }
}

Stop-Transcript
