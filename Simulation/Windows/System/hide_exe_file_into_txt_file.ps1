<# T1564.004 - Hide Artifacts: NTFS File Attributes
   Extended Attributes (EA) and Alternate Data Streams can be used to store arbitrary data (and even complete files).
   Adversaries may store malicious data or binaries in file attribute metadata instead of directly in files. 
   This may be done to evade some defenses, such as static indicator scanning tools and anti-virus.
#>

#Declare Variables 
$exeFile = ".\hello.exe"
$txtFile = ".\test.txt"

#Check if the exeFile and txtFile are given as argument 
if ($args.count -gt 0){
    $exeFile = $args[0]
    $txtFile = $args[1]
}

try{
    Get-Content $exeFile -Raw | Set-Content $txtFile -Stream hello.exe
    Get-Item $txtFile -Stream *
}
catch{
    Write-Error "Error : $_"
}
