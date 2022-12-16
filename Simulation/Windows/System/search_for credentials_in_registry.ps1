# T1552.002 - Unsecured Credentials: Credentials in Registry
# Work in progress

$strings = @('admin','password','Password','mot de passe','license','Credential','credential','login','Login','key')
#Search all registry subkeys for passwords
$Results = @()

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
            Get-ChildItem -path "$regpath" -Recurse -ErrorAction SilentlyContinue | 
            ForEach-Object {  
                Get-ItemProperty $_.pspath |
                ForEach-Object {
                    $Result = New-Object -TypeName psobject
                    $Result | Add-Member -MemberType NoteProperty -Name "Name" -Value $_.Name
                    $Result | Add-Member -MemberType NoteProperty -Name "Property" -Value $_.Property
                    $Result | Add-Member -MemberType NoteProperty -Name "Value" -Value $_.Value
                    If($Result.Name -ne $null){
                        $Results += $Result
                    }
                }
        }
        }
    }
}

# reg query HKCU /f password /t REG_SZ /s


#Filter results
foreach($string in $strings){
  $Results | Where-Object {$_.Property -like "$string"}
}
