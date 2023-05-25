### Users opening .rdp manually:
ref: https://twitter.com/mthcht/status/1646922067093200897?s=20

A double click on a .rdp file generates the following traces:
  - Sysmon EID 12 & 13 with process `explorer.exe` and target registry key containing `*\Explorer\*.rdp*`
  - Sysmon EID 1/Security EID 4688 with parent process `explorer.exe` and process `mstsc.exe` with cmdline containing `mstsc*\*.rdp`
