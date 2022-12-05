param([switch] $help )
if ($help)
{
    Write-Host "Example Usage ('dd/MM/yyyy format'): powershell -ExecutionPolicy Bypass -File .\change_system_date.ps1 "5/12/2022 23:46""
    exit
}
# Get the current date
$currentDate = (Get-Date).ToString('dd/MM/yyyy')
# Get arguments
$dateToChangeTo = $args[0]
# Change date
Set-Date -Date $dateToChangeTo
# Output the new date
Write-Host "The system date was changed from $currentDate to $dateToChangeTo"
