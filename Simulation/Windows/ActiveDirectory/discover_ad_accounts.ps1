# Domain name as argument
Param($Domain)

# We import the ActiveDirectory module without the need to install it on the current computer, the dll has been extracted from a Windows 10 x64 with RSAT installed
# technique used by real attackers
Import-Module .\Microsoft.ActiveDirectory.Management.dll 

$objDomain = Get-ADDomain -Identity $Domain 
 
# Get all user accounts from the domain 
$objUsers = Get-ADUser -Filter * -SearchBase $objDomain.DistinguishedName 
 
# Iterate through each user and display the username and export to csv
$Results = foreach ($objUser in $objUsers){
    try{
        [PSCustomObject]@{
            'Username' = $objUser.SamAccountName
            'Full Name' = $objUser.Name
        }
    }
    catch{
        Write-Warning $_.Exception.Message
    }
}

$ScriptPath = Split-Path -Parent $script:MyInvocation.MyCommand.Path
$Results | Export-Csv -Path ($ScriptPath + "\UserInfo_" +"$Domain" +".csv") -NoTypeInformation
