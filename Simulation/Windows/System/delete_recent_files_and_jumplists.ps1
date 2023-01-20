<#
    T1070.004 - Indicator Removal: File Deletion
    T1070.009 - Clear Persistence
    Delete Recent Items and jumplists 
#>

try{
    Write-Host -ForegroundColor Cyan "Deleting Recent Files links...."
    $RecentFilesPath = "$env:APPDATA\Microsoft\Windows\Recent\"
    $RecentFiles = Get-ChildItem -Path $RecentFilesPath -File -Force -Recurse

    foreach ($RecentFile in $RecentFiles){
        Remove-Item -Path $RecentFile.FullName -Force -Verbose
    }
    $CountFiles = (Get-ChildItem -Path $RecentFilesPath -File -Force -Recurse).Count
    if($CountFiles -eq 0){
        Write-Host -ForegroundColor Green "Sucess: All the recent files are deleted"
    }
    else{
        Write-Host -ForegroundColor Red "There is still $CountFiles File(s) link(s) in the recent files folder"
    }
}
catch{
    Write-Host -ForegroundColor Red "`nError Recent Files: $_"
}
try{
    Write-Host -ForegroundColor Cyan "Deleting Jumlists entries...."
    $jumplistpath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs"
    $Jumplistcontent = Get-ChildItem $jumplistpath -Recurse

    Remove-ItemProperty $jumplistpath -Name *
    foreach ($key in $Jumplistcontent) {
        $items = Get-Item $key.PSPath
        foreach($item in $items.Property){
            $itempath = "$jumplistpath\"+ $key.PSChildName
            Remove-ItemProperty $itempath -Name $item -Force -Verbose
        }
    }
    if(((Get-Item $jumplistpath).Property).Count -eq 0){
        Write-Host -ForegroundColor Green "Sucess: Jumlists deleted"
    }
}
catch{
    Write-Host -ForegroundColor Red "`nError Jumplists: $_"
}
