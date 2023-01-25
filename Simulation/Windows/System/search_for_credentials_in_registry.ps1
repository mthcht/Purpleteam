<#
    T1552.002 - Unsecured Credentials: Credentials in Registry
    T1012 - Query Registry
    Simple script to search credentials in registry with "Get-ChildItem" or "reg query"
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

$strings = @('password','licensekey')
#Search all registry subkeys for passwords
$Results = @()
#Search all registry subkeys for passwords


$registryKeys = @(
"Software\Microsoft\Windows\CurrentVersion\Run",
"Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run",
"Software\Microsoft\Windows NT\CurrentVersion\Winlogon",
"Software\Microsoft\Windows\CurrentVersion\Internet Settings\UserPasswords",
"Software\Microsoft\Windows\CurrentVersion\Credentials",
"Software\Microsoft\Credentials",
"Software\Microsoft\Protected Storage System Provider",
"Software\Microsoft\Cryptography",
"Software\Microsoft\Cryptography\Credentials",
"Software\Microsoft\Cryptography\Protect\Providers",
"Software\Microsoft\Internet Explorer\IntelliForms\Storage2",
"Software\Microsoft\Internet Explorer\IntelliForms\SPW",
"Software\Microsoft\Windows NT\CurrentVersion\Windows",
"Software\Microsoft\Windows NT\CurrentVersion\Winlogon",
"Software\Microsoft\Protect",
"Software\Microsoft\Windows\CurrentVersion\AppHost",
"Software\Microsoft\Windows\CurrentVersion\Uninstall",
"Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders",
"Software\Microsoft\Windows\CurrentVersion\Internet Settings\Cache",
"Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap",
"Software\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles",
"Software\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures",
"Software\Microsoft\Windows\CurrentVersion\RunOnce",
"Software\Microsoft\Windows\CurrentVersion\RunOnceEx",
"Software\Microsoft\Windows\CurrentVersion\RunServices"
)

$registrypaths = @("HKLM","HKCU")

foreach($registrypath in $registrypaths){
    foreach($registrykey in $registryKeys){
        $regpath = "$registrypath"+':\'+"$registrykey"
        if (Test-Path $regpath) {
            Write-Host $regpath
            Get-ChildItem -path $regpath -Recurse -ErrorAction SilentlyContinue | 
            ForEach-Object {  
                Get-ItemProperty $_.pspath |
                ForEach-Object {
                    $Result = [PSCustomObject]@{
                        regpath = "$regpath"
                        Name = "$_.Name"
                        Property = "$_.Property"
                        Value = "$_.Value"
                    }
                    foreach($string in $strings){
                        If($Result.Name.Contains("$string") -or $Results.Value.Contains("$string") -or $Results.Property.Contains("$string")){
                            Write-Host "`n`n ---- ok `n`n $Result `n ---"
                            $Results += $Result
                        }
                    }
                }
            }
        }
    }
}




$date = Get-Date -UFormat %s
$resultfile =  ".\result_string_$date.txt"
if(!(Test-Path $resultfile)){
    New-Item -Path $resultfile -ItemType File
}
else{
    Clear-Content -Path $resultfile
}

foreach($result in $Results){
    Add-Content -Path $resultfile -Value "`n $result `n" -Encoding Ascii 
}

#simulate other method reg query (easily detected):
foreach($string in $strings){
    $add = reg query HKCU /f $string /t REG_SZ /s
    Add-Content -Path $resultfile -Value "`n reg query $registrypath with $string result: $add" 
}

Stop-Transcript
