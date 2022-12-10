# T1201 - Password Policy Discovery
# We import the ActiveDirectory module without the need to install it on the current computer, the dll has been extracted from a Windows 10 x64 with RSAT installed
# technique used by real attackers

Import-Module .\Microsoft.ActiveDirectory.Management.dll

# Get the password policy of the current domain
$PasswordPolicy = Get-ADDefaultDomainPasswordPolicy

# Output to the console the policy settings
Write-Output "Minimum Password Length: $($PasswordPolicy.MinPasswordLength)"
Write-Output "Password Must Meet Complexity Requirements: $($PasswordPolicy.PasswordComplexity)"
Write-Output "Password Reuse Policy: $($PasswordPolicy.PasswordReuseHistoryCount)"
Write-Output "Password History Count: $($PasswordPolicy.PasswordHistoryCount)"
Write-Output "Minimum Password Age: $($PasswordPolicy.MinimumPasswordAge.TotalDays) days"
Write-Output "Maximum Password Age: $($PasswordPolicy.MaximumPasswordAge.TotalDays) days"
Write-Output "Lockout Duration: $($PasswordPolicy.LockoutDuration)"
Write-Output "Lockout Threshold: $($PasswordPolicy.LockoutThreshold)"
Write-Output "Lockout Observation Window: $($PasswordPolicy.LockoutObservationWindow)"

# Change the password policy
# Set-ADDefaultDomainPasswordPolicy -ComplexityEnabled $false -MaxPasswordAge 60 -MinPasswordAge 0 -MinPasswordLength 10 -PasswordHistoryCount 10 -ReversibleEncryptionEnabled $false
