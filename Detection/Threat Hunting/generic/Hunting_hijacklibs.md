## Database Hijacklibs
The database contains 386 Sideloading, 89 Environment Variable, 12 Phantom and 9 Search Order entries.

## What is DLL Hijacking?
DLL Hijacking is, in the broadest sense, tricking a legitimate/trusted application into loading an arbitrary DLL. Defensive measures such as AV and EDR solutions may not pick up on this activity out of the box, and allow-list applications such as AppLocker may not block the execution of the untrusted code. There are numerous examples of threat actors that have been observed to leaverage DLL Hijacking to achieve their objectives.

see more at  https://hijacklibs.net/

## Lookup creation for Splunk
Using a python script, we create a csv file containing all the hijacklibs data from all the yaml files in the repo

- more details here https://github.com/mthcht/awesome-lists/tree/main/Hijacklibs
- script: https://github.com/mthcht/awesome-lists/blob/main/Hijacklibs/hijacklibs.py
- lookup hijacklibs_list.csv result: https://raw.githubusercontent.com/mthcht/awesome-lists/main/Hijacklibs/hijacklibs_list.csv

## Using the list to Hunt with Splunk

### sample content of the hijacklibs_list.csv:

|file_name   |expected_file_path                                                           |vulnerable_file_name                              |file_type  |file_hash|link                                                                                                                                                                             |hijacklib_link                                |
|------------|-----------------------------------------------------------------------------|--------------------------------------------------|-----------|---------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------|
|mscorsvc.dll|`C:\Windows\Microsoft.NET\Framework\v*`;`*:\Windows\Microsoft.NET\Framework64\v*`|`*:\Windows\Microsoft.NET\Framework\v*\mscorsvw.exe`|Sideloading|         |https://decoded.avast.io/threatintel/apt-treasure-trove-avast-suspects-chinese-apt-group-mustang-panda-is-collecting-data-from-burmese-government-agencies-and-opposition-groups/|HijackLibs/yml/microsoft/built-in/mscorsvc.yml|

In this scenario, the executable `mscorsvw.exe` is vulnerable to DLL Sideloading attacks. Typically located in either `*:\Windows\Microsoft.NET\Framework\v*` or `*:\Windows\Microsoft.NET\Framework64\v*`, this executable is expected to load the `mscorsvc.dll` DLL from these specific directories.
Any instance of `mscorsvw.exe` loading `mscorsvc.dll` from an unauthorized or unexpected location should be considered a potential exploitation target and warrants immediate investigation.

### Setting up the lookup on Splunk
- you upload the lookup `hijacklibs_list.csv` on Splunk
- create a definition lookup named `hijacklibs_list` for the lookup `hijacklibs_list.csv`

### [Generic] Hunt for files in unexpected locations
```
`wineventlog` file_name=* file_path=*
| lookup hijacklibs_list file_name as file_name OUTPUT expected_file_path file_name as metadata_file_name file_hash as metadata_file_hash vulnerable_file_name as metadata_vulnerable_file_name file_type as metadata_file_type link as metadata_link hijacklib_link as metadata_hijacklib_link
| where isnotnull(expected_file_path) 
| rex field=file_path "^(?<real_file_path>.*\\\\)([^\\\\]+)$"
| makemv delim=";" expected_file_path
| mvexpand expected_file_path
| search NOT
    [| inputlookup hijacklibs_list 
     | eval expected_file_path=split(expected_file_path, ";")
     | mvexpand expected_file_path
     | table  expected_file_path file_name
     | rename  expected_file_path as real_file_path]
| bucket _time as time span=1h
| stats 
  values(metadata_file_name)
  values(metadata_file_hash)
  values(metadata_vulnerable_file_name)
  values(metadata_file_type)
  values(metadata_link)
  values(metadata_hijacklib_link)
  earliest(_time) as firsttime
  latest(_time) as lasttime
  count by  file_name real_file_path expected_file_path file_path time dest_nt_host
| rename values(*) as *
| fields - time
```

### Hunt for loaded image in unexpected location 

Example with Sysmon EventID 7 (image loaded)
```
`wineventlog` signature_id=7  loaded_file=* 
| lookup hijacklibs_list file_name as loaded_file OUTPUT expected_file_path file_name as metadata_file_name file_hash as metadata_file_hash vulnerable_file_name as metadata_vulnerable_file_name file_type as metadata_file_type link as metadata_link hijacklib_link as metadata_hijacklib_link
| where isnotnull(expected_file_path) 
| rex field=ImageLoaded "^(?<real_file_path>.*\\\\)([^\\\\]+)$"
| makemv delim=";" expected_file_path
| mvexpand expected_file_path
| search NOT
    [| inputlookup hijacklibs_list 
     | eval expected_file_path=split(expected_file_path, ";")
     | mvexpand expected_file_path
     | table  expected_file_path file_name
     | rename  expected_file_path as real_file_path, file_name as loaded_file]
| bucket _time as time span=1h
| stats 
  values(metadata_file_name)
  values(metadata_file_hash)
  values(metadata_vulnerable_file_name)
  values(metadata_file_type)
  values(metadata_link)
  values(metadata_hijacklib_link)
  earliest(_time) as firsttime
  latest(_time) as lasttime
  count by expected_file_path real_file_path loaded_file ImageLoaded time dest_nt_host
| rename values(*) as *
| fields - time
```

### Hunt for the presence of vulnerable executable hashes
```
`wineventlog` file_hash=*
| lookup hijacklibs_list file_hash as file_hash OUTPUT expected_file_path file_name as metadata_file_name file_hash as metadata_file_hash vulnerable_file_name as metadata_vulnerable_file_name file_type as metadata_file_type link as metadata_link hijacklib_link as metadata_hijacklib_link
| where isnotnull(file_hash)
| stats 
  values(metadata_file_name)
  values(metadata_file_hash)
  values(metadata_vulnerable_file_name)
  values(metadata_file_type)
  values(metadata_link)
  values(metadata_hijacklib_link)
  values(file_name)
  values(file_path)
  values(expected_file_path) 
  earliest(_time) as firsttime
  latest(_time) as lasttime
  count by _time dest_nt_host
| rename values(*) as *
```

