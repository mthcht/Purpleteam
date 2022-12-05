# Create 20 local users
$userName = "mthcht_test"
#Create random key password
$randomkey = -join ( (43..69) + (15..39) + (43..56) | Get-Random -Count 34 | % {[char]$_})
#Convert password to SecureString so we can use it with the New-LocalUser function
$Password = ConvertTo-SecureString $randomkey –AsPlainText –Force
# Create 20 local users
for ($i=1; $i -le 20; $i++) {
  New-LocalUser -Name "$userName$i" -Password $Password -FullName "$userName$i" -Description "Purpleteam Simulation $userName$i"
}
#Wait 10 seconds
Start-Sleep -Seconds 10
# Delete the new local users
for ($i=1; $i -le 20; $i++) {
  Remove-LocalUser -Name "$userName$i"
}
