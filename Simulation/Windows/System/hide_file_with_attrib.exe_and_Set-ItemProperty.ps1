<# T1564.001 - Hide Artifacts: Hidden Files and Directories
for example WannaCry uses attrib +h to make some of its files hidden
Set-ItemProperty command in this script will do the same as attrib but will probably would not be detected as easily
#>

Param(
    [string]$attribPath
)

# If $attribPath is not specified, create a file named 'file_to_hide.txt' in the current directory
if(-not $attribPath){
    New-Item -Path .\ -Name 'file_to_hide.txt' -ItemType 'file'
    $attribPath = ".\file_to_hide.txt"
}

# Try to set the hidden attribute for the path specified in $attribPath with attrib.exe and Set-ItemProperty. If the path does not exist, throw an error.
try
{
    if(-not (Test-Path $attribPath)){
        throw "The path '$attribPath' does not exist"
    }
    
    #Method1 - Set the hidden attribute of the specified path using Set-ItemProperty
    Set-ItemProperty -Path $attribPath -Name 'Attributes' -Value 'Hidden'

    #Method2 - Alternatively, set the hidden attribute of the specified path using the 'attrib' command
    & 'attrib.exe' +h $attribPath
}
catch
{
    Write-Warning "An error occurred while running the script: $_"
}
