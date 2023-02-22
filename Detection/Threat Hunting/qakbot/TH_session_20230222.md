# Threat Hunting Session for Quakbot recent behavior (20230222)
Based on observed behaviors from [raw content](https://raw.githubusercontent.com/mthcht/Purpleteam/main/Detection/Threat%20Hunting/qakbot/_raw_20230222.txt)

## Useful Keywords:

- `url`: 
- `file_path`:
- `process_command`:

### Splunk searches: 
We assume the logs are normalized, replace the fields names with your own mapping...

here we use:
- `process_command` = contain full commandline of process
- `process` = contain process name or path
- `file_name` = contain name of the file or full path with the file name
- `file_path` = contain full path with the name of the file
- `dest_ip` = destination IP address
- `dest_port` = destination port number
- `url` = full url accessed
- `dest_nt_domain` = domain name accessed
- `file_hash` = must contain all type of hashes
- `tag=process` = contains all log sources containing process execution traces
 
#### Behavior searches (specific behavior that could be a used as detection for qakbot):

- **Suspicious OneNote Child Process 2023**
```
tag=process parent_process="*onenote.exe"
AND
(
    process IN ("*AppVLP*","*bash*","*bitsadmin*","*certoc*","*certutil*","*cmd.*","*cmstp*","*control*","*cscript*","*curl*","*forfiles*","*hh.exe*","*ieexec*","*installutil*","*javaw*","*mftrace*","*Microsoft.Workflow.Compiler*","*msbuild*","*msdt*","*mshta*","*msidb*","*msiexec*","*msxsl*","*odbcconf*","*pcalua*","*powershell*","*pwsh*","*regasm*","*regsvcs*","*regsvr32*","*rundll32*","*schtasks*","*scrcons*","*scriptrunner*","*sh.exe*","*svchost*","*verclsid*","*wmic*","*workfolders*","*wscript*","*explorer.exe*")
  OR
    process_command IN ("*AppVLP*","*bash*","*bitsadmin*","*certoc*","*certutil*","*cmd.*","*cmstp*","*control*","*cscript*","*curl*","*forfiles*","*hh.exe*","*ieexec*","*installutil*","*javaw*","*mftrace*","*Microsoft.Workflow.Compiler*","*msbuild*","*msdt*","*mshta*","*msidb*","*msiexec*","*msxsl*","*odbcconf*","*pcalua*","*powershell*","*pwsh*","*regasm*","*regsvcs*","*regsvr32*","*rundll32*","*schtasks*","*scrcons*","*scriptrunner*","*sh.exe*","*svchost*","*netstat*","*net.exe*","*net1.exe*","*verclsid*","*wmic*","*workfolders*","*wscript*","*explorer.exe*","*.hta*","*.vb*","*.wsh*","*.js*","*.ps*","*.scr*","*.pif*","*.bat*","*.jse*","*.cmd*","*https://*,"*http://*","","*\\AppData\\*","*Users\\Public\\*","*ProgramData\\*","*Windows\\Tasks\\*","*Windows\\Temp\\*","*Windows\\System32\\Tasks\\*","*.dat*","*.wsf*","*.vbs*","*.dll*,"*.gif*","*.chm*","*.msi*")
  OR
    file_path IN ("*\\AppData\\*","*Users\\Public\\*","*ProgramData\\*","*Windows\\Tasks\\*","*Windows\\Temp\\*","*Windows\\System32\\Tasks\\*")
)
```

#### process_command searches:

#### file_name, file_path searches:

#### dest_ip, dest_port searches:

#### url, dest_nt_domain searches:

#### file_hash searches:
