# Detect PSEXEC

PSExec is a tool designed for system administrators, facilitating remote command execution, and is part of the Sysinternals Suite. However, this tool is frequently exploited for lateral movement by Threat Actors.

If PSEXEC is legitimately used within your environment, it's advisable to establish a custom path for its installation. By doing so, you can specifically search for executions of PSEXEC from other directories.

## Detecting PSEXEC and similar tools:

### Windows Security EventID 5140 & 5145:
When executing [PSEXEC](https://learn.microsoft.com/en-us/sysinternals/downloads/psexec) :
- The field `RelativeTargetName` contains the strings `*-stdin`, `*-stdout` or `*-stderr`
- The field `RelativeTargetName` contains the string `psexecsvc*`

When executing PSEXEC from Impacket [psexec.py](https://github.com/fortra/impacket/blob/master/examples/psexec.py) (uses a version of RemCom):
- The field `RelativeTargetName` can contain:
  - `*Remcom_Communication`
  - `RemCom_stdin*`
  - `RemCom_stderr*`
  - `RemCom_stdout*`
  - `svcctl`
- and the field `ShareName` with the value`\\\\*\\IPC$*` (\\*\IPC$)
- The executable dropped in the share `admin$`:
  - The field `ShareName` = `\\\\*\\Admin$*`
  - The field `RelativeTargetName` with a name ending with `*.exe` or `*.dll`
  - The field `AccessMask` with the value `0x2`

### Windows Security EventID 4697, 7045 or  7036 (on the remote host):
When executing [PSEXEC](https://learn.microsoft.com/en-us/sysinternals/downloads/psexec) :
- The field `ImagePath` = `*PSEXESVC.exe` (PSEXESVC.exe is copied to the %SystemRoot% directory by default)
- The field `ServiceName` = `*PSEXESVC*` (make sure ServiceName is parsed in EventID 7036, you may see 'PSEXESVC service state has changed' when starting and stopping psexec)

You can search for windows Security EventID 4624 (LogonType 3) near the time when EventID 7045 is logged on the machine to get the source address of the remote computer by pivoting on the SID of the user in EventID 7045

If [PSEXEC](https://learn.microsoft.com/en-us/sysinternals/downloads/psexec) is executed with the -r argument (Specifies the name of the remote service to create or interact with), we won't see the ServiceName PSEXECSVC in the EventID 7045, we should still see:
- The field ImagePath containing %SystemRoot% and ending with .exe
- The field ServiceType = `user mode service`
- The field StartType = `demand start` or `3`
- The field ServiceAccount = `LocalSystem` or `0x10`

and Sysmon EventID 1 we should still be able to detect default PSEXEC from microsoft with the field OriginalFileName = `*psexesvc.exe*` with the process_name different than `PSEXESVC.exe*`or `*psexec*`


Service creation from psexec.py from impacket and psexec from Metasploit is more difficult to detect, we should see a randomly generated string of 8 upper and lowercase letters for psexec of Metasploit in the field `ServiceName` of the EventID 4697 or a randomly generated string of 16 upper and lowercase letters for psexec of Metasploit in the field `ServiceName` of the EventID 7045`(and 4 upper and lowercase letters for psexec from impacket - may generate too many false positives)

### Windows Security EventID 4674:
An operation was attempted on a privileged object:
- The field ObjectName = `*PSEXESVC*`

### Sysmon EventID 13 (on the source host):
Registry value set:
- The field TargetObject = `*\SOFTWARE\Sysinternals\PsExec\EulaAccepted*`

### Process execution with Windows Security EventID 4688/4689 or Sysmon EventID 1&3 or Powershell 4104 or Linux auditd/sysmon process execution:
Detect one of these keywords in the field `CommandLine` or `process` (should include process name with full path and command line executed) or even ScriptBlockText (powershell script content):
 - `*PSEXECSVC*`
 - `*PsExec.exe*`
 - `*PsExec64.exe*`
 - `* -accepteula -nobanner -d cmd.exe /c*` (common argument)
 - `*ps.exe -accepteula*` (common argument)
 - `*psexec.exe * -r *` (if we just want to see the use of a custom name)
 - `*psexec64.exe * -r *` (if we just want to see the use of a custom name)
 - `*remcom.exe*` (remcom)
 - `*.exe" \\* /user:* /pwd:* cmd.exe*` (remcom common argument)
 - `*smb-psexec.nse*` (nmap nse script)
 - `*psexec_ms17_010.rb*` (metasploit)
 - `*ms17_010_psexec.*` (metasploit)
 - `*/psexec.json*` (metasploit)
 - `*\psexec.json*` (metasploit)
 - `*PsExecLiveImplant*` (koadic)
 - `*/exec_psexec*` (koadic)
 - `*psexec.py*` (impacket)
 - `*impacket-psexec*` (impacket)
 - `*psexec_windows.exe*` (impacket)
 - `*jump-exec psexec*` (havoc)
 - `*/Jump-exec/Psexec*`(havoc)
 - `*PsExecLog.log*` (gofetch)
 - `*Invoke-PsExec*` (empire + AutoRDPwn)
 - `*\tools\psexec.rb*` (empire)
 - `*/tools/psexec.rb*` (empire)
 - `*/smb/psexec.rb*` (empire)
 - `*\smb\psexec.rb*` (empire)
 - `*-PsExecCmd*` (empire)
 - `*PSEXEC_PSH*` (angrypuppy)
 - `*Ladon psexec*` (ladon)
 - `*jump psexec_psh*` (cobaltstrike)
 - `*jump psexec64*` (cobaltstrike)
 - `*bpsexec_psh*` (pycobalt)
 - `*bpsexec_command*` (pycobalt)
 - `*invoke-psexecpayload*` (poshc2)
 - `*PsExecMenu(*` (Redpeanut)
 - `*sharppsexec*` (Redpeanut)
 - `*SharpPsExecManager*` (Redpeanut)
 - `*SharpPsExecService*` (Redpeanut)
 - `*Commands/PsExecCommand.*` (SharpC2)
 - `*SharpNoPSExec*` (SharpNoPSEXEC)
 - `* --target=* --payload=*cmd.exe /c*` (SharpNoPSEXEC)
 - `*Plugins\Execution\PSExec*` (TokenVator)
 - `*LateralMovement_PassTheTicket_ByPsexec.py*` (ViperC2)
 - `*Lateral/PSExec.cs*` (WheresMyImplant)
 - `*Lateral\PSExec.cs*` (WheresMyImplant)
 - `*wmiexec.py*` (wmiexec)
 - `*smbexec.py*` (smbexec)
 - `*dcomexec.py*` (impacket)

These keywords are taken from the [ThreatHunting-keywords](https://github.com/mthcht/ThreatHunting-Keywords) project, more keywords are available for each psexec like tools in the csv.

*While I have provided a detailed overview of the detection for PSEXEC, i will not be offering such comprehensive summaries for each individual tool here (may be reserved for another post)*

#### Sysmon EventID 11,23,26,29:
All the keywords above also apply to the file manipulation events using the field TargetFilename 

#### Windows Security EventID 4648:
ProcessName = `*PSEXEC*` (depends on the usage)

### Sysmon EventID 17 & 18:
Pipe creation/access by PSEXEC, psexec.py, RemCom, PAExec, CSExec:
`PipeName` start with:
 - `psexec*`
 - `psexesvc*`
 - `paexec*`
 - `remcom*`
 - `csexec*`
 - `*-stdin`
 - `*-stderr`
 - `*-stdout`

### Microsoft Defender EventID 1116 & 1117:
- 1117 = MALWAREPROTECTION_STATE_MALWARE_ACTION_TAKEN
- 1116 = MALWAREPROTECTION_STATE_MALWARE_DETECTED

Some of the psexec like tools from metasploit or impacket can trigger alerts from Microsoft Defender, identify the signature names associated with these psexec like tools for your Anti-Virus or EDR solution your environment.

signature: 
- `VirTool:Win32/RemoteExec`
- `VirTool:Win64/RemoteExec`
- `*psexec*`
- ... (if you have more relevant signature names i would appreciate it)

### Other forensic artefacts:
All the windows logs and forensic artefact can be collected with DFIR-ORC
- Prefetch: will show the first time and the last time the PSEXEC service executable was run (*:\Windows\Prefetch\PSEXESVC.EXE-[RANDOM].pf)
- Shimcache: will also show the execution of PSEXESVC.exe with the date (but log the information at shutdown)
- AMCACHE or RecentFileCache: The first execution of the program
- MFT or USNInfo may also contain traces of the executable dropped on the disk
- EULAAccepted in registry (as seen in sysmon event ID 13 earlier)

### Detection rules on your SIEM:
When aiming to identify PSEXEC usage on a remote machine, enhance detection accuracy by correlating and incorporating the source IP address, originating user, and source workstation in your alerts to help your analysts in their investigations.

PSExec is commonly utilized in various environments, which often complicates the task of distinguishing or detecting malicious activities associated with its use, ensure that you implement a strict policy regarding the use of PSEXEC. By clearly defining the rules for its installation and usage, you can more easily detect deviations from these guidelines, enabling quicker identification of unauthorized activities


#### More Detection rules ideas on Github :

[(repo:SigmaHQ/sigma OR repo:splunk/security_content OR repo:elastic/detection-rules OR repo:The-DFIR-Report/Sigma-Rules) psexec .yml](https://github.com/search?q=%28repo%3ASigmaHQ%2Fsigma+OR+repo%3Asplunk%2Fsecurity_content++OR+repo%3Aelastic%2Fdetection-rules+OR+repo%3AThe-DFIR-Report%2FSigma-Rules%29+psexec+.yml&type=code)
