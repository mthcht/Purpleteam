#First, we will define the necessary variables
$action = 'C:\Windows\System32\cmd.exe'
$arguments = ' /c "echo ola !"'
$schedTaskName = 'Purpleteam test'
$triggerTime = (Get-Date).AddMinutes(1)

#Now, we will create the scheduled task
$schTask = New-ScheduledTaskAction -Execute $action -Argument $arguments
$taskTrigger = New-ScheduledTaskTrigger -At $triggerTime -Once
Register-ScheduledTask -Action $schTask -Trigger $taskTrigger -TaskName $schedTaskName -RunLevel Highest

#Finally, we will confirm that the task was created
$createdTask = Get-ScheduledTask -TaskName $schedTaskName
if ($createdTask) {
    Write-Output "Scheduled task '$schedTaskName' successfully created."
} else {
    Write-Output "Scheduled task '$schedTaskName' failed to be created."
}
