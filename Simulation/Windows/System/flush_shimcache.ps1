<#
    T1112 - Modify Registry
    T1070.004 - Indicator Removal: File Deletion
    T1562.001 - Impair Defenses: Disable or Modify Tools
    T1059.003 - Command and Scripting Interpreter: Windows Command Shell
    Simple script to flush shimcache
    Shimcache, also known as AppCompatCache, is a component of the Application Compatibility Database.
    This technique is a anti-forensic technique as shimcache is an important artifact for forensic investigation.
    In windows 10/11, it contains all the executable accessed throught windows explorer with the last modification time of the executables, it is not an indicator of execution.
    Could be used by Incident responder team to establish a timeline.
#>

Start-Transcript -Path "$env:tmp\simulation_traces.log" -Append

#Clears the Shim Cache, store compatibility information for applications
Invoke-Expression -Command 'Rundll32.exe apphelp.dll,ShimFlushCache'
#Clears the Base Application Compatibility Cache, which is used to store compatibility information for Windows components.
Invoke-Expression -Command 'Rundll32.exe kernel32.dll,BaseFlushAppcompatCache'
# In case you have the registry key, delete it
Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SessionManager\AppCompatCache\AppCompatCache" -Recurse -Force

#Reboot machine, this is needed to take effect as the shimcache is saved on shutdown/reboot
#$hostname = hostname
#Restart-Computer -ComputerName $hostname -Force -Confirm 

Stop-Transcript
