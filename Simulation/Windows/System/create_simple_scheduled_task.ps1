<#
    T1053.005 - Scheduled Task/Job: Scheduled Task
    T1033 - System Owner/User Discovery
    Create a simple schedule task, wait for it to trigger and delete it
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append -Force

try{
    # Define the necessary variables
    $action = 'C:\Windows\System32\cmd.exe'
    $arguments = ' /c "echo ola !&whoami&timeout 10"'
    $schedTaskName = 'Purpleteam test'
    $triggerTime = (Get-Date).AddSeconds(15)

    # Create the scheduled task
    $schTask = New-ScheduledTaskAction -Execute $action -Argument $arguments -Verbose
    $taskTrigger = New-ScheduledTaskTrigger -At $triggerTime -Once
    Register-ScheduledTask -Action $schTask -Trigger $taskTrigger -TaskName $schedTaskName -RunLevel Highest -Verbose

    # Confirm that the task was created
    $createdTask = Get-ScheduledTask -TaskName $schedTaskName -Verbose
    if ($createdTask) {
        Write-Host -ForegroundColor Green "Sucess: Scheduled task '$schedTaskName' successfully created, waiting 15 seconds to trigger the scheduled task..."
        Start-Sleep 15
        #Remove Scheduled task created
        Unregister-ScheduledTask -TaskName $schedTaskName -Confirm:$false -Verbose
        if (-not (Get-ScheduledTask -TaskName $schedTaskName -ErrorAction SilentlyContinue)) {
            Write-Host -ForegroundColor Green "Sucess: Simulation terminated, scheduled task '$schedTaskName' deleted"
        }
        else{
            Write-Host -ForegroundColor Yellow "Warning: Scheduled task '$schedTaskName' is still on the system"
        }
    }
    else {
        Write-Host -ForegroundColor Red "Failed: Scheduled task '$schedTaskName' failed to be created."
    }

}
catch{
    Write-Host -ForegroundColor Red "`nError: $_"
}

Stop-Transcript
