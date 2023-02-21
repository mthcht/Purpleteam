<#
    T1070.004 - Indicator Removal: File Deletion
    T1070.009 - Clear Persistence
    Delete Recent Items and jumplists 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Verbose -Force

try{
    Write-Host -ForegroundColor Cyan "[Info] Deleting Recent Files, folders,links...."
    $RecentFilesPath = "$env:APPDATA\Microsoft\Windows\Recent\"
    $RecentFilesReg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths"
    $RecentFiles = Get-ChildItem -Path $RecentFilesPath -File -Force -Recurse

    foreach ($RecentFile in $RecentFiles){
        Remove-Item -Path $RecentFile.FullName -Force -Verbose
    }
    $CountFiles = (Get-ChildItem -Path $RecentFilesPath -File -Force -Recurse).Count
    if($CountFiles -eq 0){
        Write-Host -ForegroundColor Green "[Sucess] All the recent files are deleted"
    }
    else{
        Write-Host -ForegroundColor Red "[Error] There is still $CountFiles File(s) link(s) in the recent files folder"
    }
    if (Test-Path $RecentFilesReg){
        Write-Host -ForegroundColor Cyan "[Info] Removing entries in $RecentFilesReg ..."
        Remove-Item $RecentFilesReg -Force -Recurse -Verbose
        if (Get-Item $RecentFilesReg){
            Write-Host -ForegroundColor Red "[Error] $RecentFilesReg still contains data"
        }
        else{
            Write-Host -ForegroundColor Green "[Sucess] $RecentFilesReg entries deleted"
        }
    }
    else{
        Write-Host -ForegroundColor Green "[Sucess] $RecentFilesReg does not exist"
    }
}
catch{
    Write-Host -ForegroundColor Red "`n[Error] Exception Recent Files: $_"
}
try{
    Write-Host -ForegroundColor Cyan "[Info] Deleting Jumlists entries...."
    $jumplistpath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs"
    $Jumplistcontent = Get-ChildItem $jumplistpath -Recurse -Verbose

    Remove-ItemProperty $jumplistpath -Name *
    foreach ($key in $Jumplistcontent) {
        $items = Get-Item $key.PSPath
        foreach($item in $items.Property){
            $itempath = "$jumplistpath\"+ $key.PSChildName
            Remove-ItemProperty $itempath -Name $item -Force -Verbose
        }
    }
    if(((Get-Item $jumplistpath).Property).Count -eq 0){
        Write-Host -ForegroundColor Green "[Sucess] Jumlists deleted"
    }
}
catch{
    Write-Host -ForegroundColor Red "`n[Error] Exception Jumplists: $_"
}

Stop-Transcript -Verbose 
