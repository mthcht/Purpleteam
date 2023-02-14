<#
    T1482 - Domain Trust Discovery
    T1046 - Network Service Discovery
    T1069.002 - Permission Groups Discovery: Domain Groups
    Find Domain Controllers names, distinguished names, and paths
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

$dumpfile = "$env:tmp\dc_list.txt"

try{
    Write-Host -ForegroundColor Cyan "Searching for Domain Controllers..."
    $search = New-Object System.DirectoryServices.DirectorySearcher
    $search.SearchRoot = (New-Object System.DirectoryServices.DirectoryEntry)
    $search.Filter = "(primaryGroupID=516)"
    $search.SearchScope = "Subtree"
    $results = $search.FindAll()
    if ($results){
        foreach ($result in $results)
        {
            $object = $result.GetDirectoryEntry()
            Write-Host -ForegroundColor Green "Success: Found Domain Controller:`nName: $($object.name)`ndistinguishedName: $($object.distinguishedName)`nPath: $($object.Path) "
            Add-Content $dumpfile "Success: Found Domain Controller:`nName: $($object.name)`ndistinguishedName: $($object.distinguishedName)`nPath: $($object.Path) " -Force -Verbose
        }
        if ($dumpfile){
            Write-Host -ForegroundColor Green "Success: DC list added to $dumpfile"
        }
        else {
            Write-Host -ForegroundColor Red "Error: Failed to save DC list to $dumpfile"
        }
    }
    else {
        Write-Host -ForegroundColor Red "Error: Failed to find DCs"
    }
}
catch{
    Write-Host -ForegroundColor Red "Error: $_"
}

Stop-Transcript
