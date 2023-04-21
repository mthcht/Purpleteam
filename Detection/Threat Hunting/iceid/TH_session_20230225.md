# Threat Hunting Session for IceID recent behavior (20230225)
Based on observed recents behaviors from [raw content](https://raw.githubusercontent.com/mthcht/Purpleteam/main/Detection/Threat%20Hunting/iceid/_raw_20230225.txt)

Threat Hunting searches used are meant for Threat Hunting sessions and could generate a lot of false positive if used as detection rules like this.

The IOC list is not complete on purpose, we only use the most recent IOCs for the session, you should automatically add new IOCs feeds to your database (MISP,OpenCTI...) with SIEM integration and scheduled detection rules.  

We need dirty searches for Threat Hunting without Datamodel and optimizations because we want to make sure we match something without depending on the Datamodel normalization when we don't know how the SIEM is managed

### Splunk searches: 
If your logs are normalized with other fields name, just replace the fields names with your own mapping...

here we use:
- `process_command` = contain full commandline of process
- `process` = contain process name or path
- `file_name` = contain name of the file or full path with the file name
- `file_path` = contain full path with the name of the file
- `src_ip` = source IP address
- `dest_port` = destination port number
- `url` = full url accessed
- `dest_nt_domain` = domain name accessed
- `file_hash` = must contain all type of hashes
- `tag=process` = must contains all log sources with process execution traces
- `tag=proxy` = must contains all log sources with proxy users access traces
- `tag=network` = must contains all log sources with network traffic 
- `index=*` = search in all logs sources available


### Behavior searches (specific behavior that could be a used as detection for iceid):

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

- **HTTP access without domain name**
```
tag=proxy url=* NOT dest IN ("10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16") | regex url = "^(https|tunnel)\:\/\/\d*\.\d*\.\d*\.\d*"
```

- **IceID listener proxy traffic** 
```
tag=network src_ip IN (10.0.0.0/8,192.168.0.0/16,172.16.0.0/12) dest_port=50000
```

- **Office documents executing macro**
```
tag=process parent_process IN ("WINWORD.EXE","EXCEL.EXE","POWERPNT.EXE","onenote.exe","onenotem.exe","onenoteviewer.exe","onenoteim.exe","msaccess.exe")
AND (("*\\VBE7INTL.DLL*","*\\VBE7.DLL*", "*\\VBEUI.DLL*") OR (process IN ("powershell.exe","cmd.exe"))
```

---

### Keywords searches

#### process_command searches:
for this session, we will use these one (extracted from raw file) but can be anything suspicious really (lolbas mostly)
```
tag=process process_command IN ("*Start-Sleep*","*-C iwr *","* IWR *","* -uri *","* -ImagePath *","* -outfile *","* -uri http*","* Bansalague *","* Mount-DiskImage *","* kernel32,Sleep*","*.CMD reg *","*.iso *","*0 1 2 3 4 5 6 7 8 9*","*A B C D E F G H I J K L M N O P K R S T U V W X Y Z *","*Acetimeter *","*Contract_*_*_Copy#*.one*","*Contract_0*_*_Copy#*.one*","*Document_*_Unpaid_-*.pdf*","*Invoice_Docs_*#*.pdf*","*O p e n.bat*","*PERLITIC\\*","*PITCHPOT.DAT*","*POV_Document_0*.lnk*","*Paid_Offer_*_*-*.pdf*","*\\COIm.jpg*","*\\DecorateBelt\\*","*\\REF_Document.lnk*","*\\RecentDocs\\.img*","*\\RecentDocs\\.iso* ","*\\Temp\\*.bat*","*\\\LUGGAGES.lnk*","*\\command-*.img*","*\\fundraising.dat*","*\\iceid\\*","*\\jokes.txt*","*\\license.dat*","*\\outgoing.dat*","*\\pamphleteering.dat*","*\\standing.dat*","*\\them\\*.cmd*","*\\trailblazing.dat*","*\\uzughita.dll*","*\\worker.cmd*","*aimsatchiK\\*","*bogpacsipr.cmd*","*cangemoptO\\*","*cmd /c *.cmd*","*cmd /c *.lnk*","*eathipayem.cmd*","*hertbe.dll*","*hitwitgalR.cmd*","*invoke-webrequest -uri*","*jawjogfenO\\*","*kickboxing.dat*","*letetasody*","*mrassociattes.com*","*nayairguyb.cmd*","*negconrodl\\*","*outgoing.dat*","*raycatmady\\*","*redacted.document.*.*.pdf*","*redacted_file_*.*.2023.pdf*","*rundll32*.MBA*","*rundll32*.dat*","*rundll32*\\AppData\\Roaming\\*","*rundll32*\\Temp\\*","*vatphiefts.cmd*","*waroupada.exe*","*xcopy *.dat*","*xcopy *\\temp\\*")```
```

#### file_name, file_path searches:
```
index=* file_name IN ("*Contract_*_*_Copy#*.one","*Contract_0*_*_Copy#*.one","*Document_*_Unpaid_-*.pdf","*Invoice_Docs_*#*.pdf","*O p e n.bat","*PERLITIC\\*","*PITCHPOT.DAT*","*POV_Document_0*.lnk*","*Paid_Offer_*_*-*.pdf*","*\\*.img","*\\COIm.jpg*","*\\DecorateBelt\\*","*\\REF_Document.lnk*","*\\Temp\\*.","*\\Temp\\*.bat","*\\Temp\\*.cmd","*\\Temp\\*.dll","*\\Temp\\*.iso","*\\\LUGGAGES.lnk","*\\fundraising.dat","*\\jokes.txt","*\\license.dat","*\\outgoing.dat","*\\pamphleteering.dat","*\\standing.dat","*\\them\\*.cmd","*\\trailblazing.dat","*\\uzughita.dll","*aimsatchiK\\*","*bogpacsipr.cmd","*cangemoptO\\*","*eathipayem.cmd","*hertbe.dll","*hitwitgalR.cmd","*jawjogfenO\\*","*kickboxing.dat","*letetasody*","*nayairguyb.cmd","*negconrodl*","*raycatmady\\*","*redacted.document.*.*.pdf","*redacted_file_*.*.2023.pdf","*vatphiefts.cmd","*waroupada.exe*")
OR file_path IN ("*Contract_*_*_Copy#*.one","*Contract_0*_*_Copy#*.one","*Document_*_Unpaid_-*.pdf","*Invoice_Docs_*#*.pdf","*O p e n.bat","*PERLITIC\\*","*PITCHPOT.DAT*","*POV_Document_0*.lnk*","*Paid_Offer_*_*-*.pdf*","*\\*.img","*\\COIm.jpg*","*\\DecorateBelt\\*","*\\REF_Document.lnk*","*\\Temp\\*.","*\\Temp\\*.bat","*\\Temp\\*.cmd","*\\Temp\\*.dll","*\\Temp\\*.iso","*\\\LUGGAGES.lnk","*\\fundraising.dat","*\\jokes.txt","*\\license.dat","*\\outgoing.dat","*\\pamphleteering.dat","*\\standing.dat","*\\them\\*.cmd","*\\trailblazing.dat","*\\uzughita.dll","*aimsatchiK\\*","*bogpacsipr.cmd","*cangemoptO\\*","*eathipayem.cmd","*hertbe.dll","*hitwitgalR.cmd","*jawjogfenO\\*","*kickboxing.dat","*letetasody*","*nayairguyb.cmd","*negconrodl*","*raycatmady\\*","*redacted.document.*.*.pdf","*redacted_file_*.*.2023.pdf","*vatphiefts.cmd","*waroupada.exe*")
```

#### url, dest_nt_domain searches:
```
tag=proxy url IN ("*.exe","*.dll","*.dat","*.one","*allertmnemonkik.com*","*dgormiugatox.com*","*firebasestorage.googleapis.com/*.appspot.com/o/*.zip*","*plivetrakoy.com*","*klayerziluska.com*","*umousteraton.com*","*mrassociattes.com*","*aerilaponawki.com*","*alishaskainz.com*","*yelsopotre.com*","*alohaplinayagot.com*","*plitspiritnox.com*","*aerilaponawki.com*","*alishaskainz.com*","*yelsopotre.com*","*alohaplinayagot.com*","*carismorth.com*","*cootembrast.com*")
OR dest_nt_domain IN ("*allertmnemonkik.com*","*dgormiugatox.com*","*firebasestorage.googleapis.com/*.appspot.com/o/*.zip*","*plivetrakoy.com*","*klayerziluska.com*","*umousteraton.com*","*mrassociattes.com*","*aerilaponawki.com*","*alishaskainz.com*","*yelsopotre.com*","*alohaplinayagot.com*","*plitspiritnox.com*","*aerilaponawki.com*","*alishaskainz.com*","*yelsopotre.com*","*alohaplinayagot.com*","*carismorth.com*","*cootembrast.com*")
```

#### file_hash searches:
```
index=* file_hash IN ("1d769af38bea969c00501ff64b51f4e4fd2de2bedc7785b3471b7d12765c1a7d","fbeffaaf34d13cd45e2e545172db2287fead4ed05c04c0e8da549a0869d2fa96","9661ba9658bf85409cc414b8f62aaca490ac9f75aa4c2a146795945cf014b211","65281fe83e22bde20fa56079bebaea6fb353d1036be8073924fdf64cd9194984","c2e3097e2de547d70f1d4543b51fdb0c016a066646e7d51b74ca4f29c69f5a85","778f1cbd036de33d6e6eb5b0face18c276732e365111bdfae447b30ccfebf8c5","f96779056b8390e4329b2012fc1bf7bc7b55aca84665ba41c9e3674169080413","c06805b6efd482c1a671ec60c1469e47772c8937ec0496f74e987276fa9020a5","c2e3097e2de547d70f1d4543b51fdb0c016a066646e7d51b74ca4f29c69f5a85","778f1cbd036de33d6e6eb5b0face18c276732e365111bdfae447b30ccfebf8c5","f96779056b8390e4329b2012fc1bf7bc7b55aca84665ba41c9e3674169080413","c06805b6efd482c1a671ec60c1469e47772c8937ec0496f74e987276fa9020a5","7f5864e2fafc9c7cadafbd0cb763c284f4fa15d0fcdd713984f094cb0dd0a15a","b9a97302eb8e93f0e8caa9a24ebcf1334bdc21489a8373773452930791c648b9","3c0381c16a13eae17abcd3398cb388dd1ed4bb5a0919563149124502e921c155","a85729bd8d5976b67662415b7d24bcc5c1a4230304a7b2ea4830fc6a76822fba","0fbe0024554ee9aee8d6c5814bf16e33d9a90425ea7230ac72ae7f4e2df73938","c2a3da4da7ca7224821ed55795529eba98668f4b692ad38c140bacb793f26201","949e992a9a4056cd8bf69feda32d855b533b9d7b83d11468c6bbf47a9f1bbc78","265c1857ac7c20432f36e3967511f1be0b84b1c52e4867889e367c0b5828a844","3390b1d8560f565ed5e2a60df63ce24abe0ef3da514cf5645dd732f7e5cdbbae","6a904ca2f55d9dc7f8daf3b3c12a5957c3f6c1c857409ce6d6ba444498d97142","7bf32f98de23917aba056065e36e2a71d2a57d09c9fa083f920a969b1e873112","ad174760985c5418b4a3c3a97cd8d7658e3bbb7030f72f2eff9ff97e57f200bd","9c337d27dab65fc3f4b88666338e13416f218ab75c4b5e37cc396241c225efe8","681217e6c8ed3ed37c1312646afb8e0cfe25e6840f461d10a7d9cdd4ffa725cb","1ab812f7d829444dc703eeb02ea0a955ec839d5e2a9b619d44ac09a91135cad1","2624668d5150f9d8c055e312a9ca1dcb4b74994afe9678efef182063d57b5ef7","f5498dbfd2efefc4acc9ab9773d4fcbedeffa57e5a7d5d72398b86c7af93bd20","3b35d3028c35181669e6a8993164633cd8ea81664f27b5b9ef8387c78c181a5e","95ad74c1dff5293c49c955a4e77c17e6912c7b8d1fc8f5f4c6f05ac77a56a9ab","9c337d27dab65fc3f4b88666338e13416f218ab75c4b5e37cc396241c225efe8","681217e6c8ed3ed37c1312646afb8e0cfe25e6840f461d10a7d9cdd4ffa725cb","1ab812f7d829444dc703eeb02ea0a955ec839d5e2a9b619d44ac09a91135cad1","6aca19225d02447de93cbf12e6f74824371be995a17d88e264c79d15cb484b28","100345684c677d50ff837959699aaef34e583fd11d812ccef80dbfe03c0db62a","da6a91012518cd07ae61313fd108711b56f406068efb119f678a4946438c6800","db08770ab1946bc505cc5a5483767a194d7801d32f2ea6c78fd0c966d0c7bc75","74d5e62a2f6c6bcf10dfcdbcc55407be8af9662b50f2e2a2c5b33bf5e800e7e6","ad28c42b8961132b71581e7a438c3eaa7c7008577ce8bd60de44d67414a244b9","2cef187ef4a2aa3fc58ff8f67a5a5a0eb1d29fd8a7c1d7f21a8654f2bb074de3","bf06b490e30ca9a8cc4de134f82a20af3299c107c457ef29ff1cff213d0bba1c","348110a61e369a448b64fa3fb8009a48b7a54bcec3b1af4e3f532f4092d09a39","0f229335c60fc3ce5b302ba16c2befbf8ff8f2f3938fdc9891e54b0841dc1daa","354c059e6f6a7d52046855496e9bbcff","88a254de852e3ba553da1af698215973","6474da79ff6331712c6a2c5cbadc9051","ad0436f20e1ecd7fdf9b4d147d8db2da")
```

#### Heavy search on raw log (without parsing)  :
- 1.upload keywords_list.csv to your SIEM
- 2.create a lookup definition named keywords_list for keywords_list.csv and add WILDCARD(keyword) in the advanced option of the lookup for this search to work, modify permissions of the lookup to be able to read it
- 3 search:

```
index=* | lookup keywords_iceid_list keyword as _raw OUTPUT keyword as keyword_detection 
| stats count ealiest(_time) as firsttime latest(_time)- as lasttime values(_raw) by keyword_detection index sourcetype 
| convert ctime(*time)
```
