<#
    T1420 - File and Directory Discovery
    Simple script show files with write permissions for the current user
#>

# Get the directory path
if($args.Length -eq 0){
    $directoryPath = Get-Location
}
else{
    $directoryPath = $args[0]
}

# Get a list of all files in the directory
$files = Get-ChildItem $directoryPath -Recurse

# Loop through all the files
foreach ($file in $files){
    # Check if the user has write permissions
    $accessRule = (Get-Acl $file.FullName).Access | Where-Object {$_.IdentityReference -like "*$env:USERNAME*" -and (($_.FileSystemRights -match "Write" ) -or ($_.FileSystemRights -match "FullControl"))}
    
    # If the user has write permissions, display the file name
    if($accessRule){
        Write-Output "The user has write permission for the file: $($file.FullName)"
    }
}
