# T1136.001 - Create Account: Local Account
# T1531 - Account Access Removal


#Create user
$userName = "mthcht_test"
#Create random key password
$randomkey = -join ( (43..69) + (15..39) + (43..56) | Get-Random -Count 34 | % {[char]$_})
#Convert password to SecureString so we can use it with the New-LocalUser function
$Password = ConvertTo-SecureString $randomkey –AsPlainText –Force
#Create the new user mthcht_test
New-LocalUser -Name $userName -Password $Password -FullName "mthcht_test" -Description "Purpleteam Simulation"
#Wait 10 seconds
Start-Sleep -Seconds 10
#Delete mthcht_test
Remove-LocalUser -Name $userName
