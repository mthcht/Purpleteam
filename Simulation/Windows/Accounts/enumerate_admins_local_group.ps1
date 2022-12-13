# T1069.001 - Permission Groups Discovery
# This script will detect local groups with admin privileges, enumerate them and save the result to a csv file

#Get the current directory
$currentDirectory = Get-Location

#Get all groups
$LocalGroups = Get-LocalGroup

#Filter groups to get only Administrators
$AdminGroups = $LocalGroups | Where-Object {$_.Sid -match "S-1-5-32-544"}


#Create an array to hold the output
$OutputArray = @()

Foreach($Group in $AdminGroups){
    #Display Group Name
    Write-Host $Group.Name
    #Enumerate Local Group Members
    $LocalGroupMembers = Get-LocalGroupMember -Group $Group

    #Display Local Administrators Group Members
    $LocalGroupMembers | Format-Table -AutoSize
    $LocalGroupMembers | ForEach-Object {
        $MemberClass = $_.ObjectClass
        $MemberName = $_.Name
        $MemberType = $_.PrincipalSource 

        #Create a custom object to hold the data
        $OutputObject = New-Object PSObject
         
        #Add Properties to the Object
        $OutputObject | Add-Member -MemberType NoteProperty -Name GroupName -Value $Group
        $OutputObject | Add-Member -MemberType NoteProperty -Name MemberClass -Value $MemberClass
        $OutputObject | Add-Member -MemberType NoteProperty -Name MemberName -Value $MemberName
        $OutputObject | Add-Member -MemberType NoteProperty -Name PrincipalSource -Value $MemberType 

        #Add the Object to the Output Array
        $OutputArray += $OutputObject
    }
}

#Export the Array to CSV
$OutputArray | Export-Csv -Force -Path $currentDirectory\LocalAdminGroupMembers.csv -NoTypeInformation
