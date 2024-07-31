# Crowdstrike scams 

## Hunting
- [suspicious_domains.csv](https://github.com/mthcht/Purpleteam/blob/main/Detection/Threat%20Hunting/CROWDSTRIKE_BSOD_scams/IOCS/suspicious_domains.csv)
  - check https://urlscan.io/search/#crowdstrike*%20date%3A%3Enow-7d%20 regularly to add new suspicious domains
  - check DNSTWIST new resolving IP address  https://github.com/mthcht/awesome-lists/blob/main/Lists/DNSTWIST/crowdstrike.com_dnstwist_list.csv
    
Observed in samples:
- `api.telegram.org` (high FP risk)
- `icanhazip.com` (high FP risk)
- `copy Carroll Carroll.cmd & Carroll.cmd & exit`
- `findstr /I "avastui.exe avgui.exe bdservicehost.exe nswscsvc.exe sophoshealth.exe`
- `findstr /V "locatedflatrendsoperating" Ukraine`
- `cmd /c copy /b Treating + Viagra + Vision + Jul + Str 564784\L`
- `taskkill /F /IM chrome.exe` (FP risk)


## IOCS reports:
### references:
  - https://www.crowdstrike.com/blog/threat-actor-distributes-python-based-information-stealer/
  - https://www.crowdstrike.com/blog/fake-recovery-manual-used-to-deliver-unidentified-stealer/
  - https://www.crowdstrike.com/blog/likely-ecrime-actor-capitalizing-on-falcon-sensor-issues/
  - https://www.crowdstrike.com/blog/lumma-stealer-with-cypherit-phishing-lure/
  - https://app.any.run/tasks/14fc6a8a-6fd7-431f-aba5-d3177b47690f/
  - https://www.sentinelone.com/blog/crowdstrike-global-outage-threat-actor-activity-and-risk-mitigation-strategies/
  - https://any.run/cybersecurity-blog/crowdstrike-outage-abuse/
  - https://www.virustotal.com/gui/file/803727ccdf441e49096f3fd48107a5fe55c56c080f46773cd649c9e55ec1be61/detection
  - https://www.crowdstrike.com/blog/malicious-inauthentic-falcon-crash-reporter-installer-spearphishing/
  - https://www.crowdstrike.com/blog/malicious-inauthentic-falcon-crash-reporter-installer-ciro-malware/


### IOCs:
- [malicious_urls.csv](https://github.com/mthcht/Purpleteam/blob/main/Detection/Threat%20Hunting/CROWDSTRIKE_BSOD_scams/IOCS/malicious_urls.csv)
- [malicious_strings.csv](https://github.com/mthcht/Purpleteam/blob/main/Detection/Threat%20Hunting/CROWDSTRIKE_BSOD_scams/IOCS/malicious_strings.csv)
- [malicious_ip.csv](https://github.com/mthcht/Purpleteam/blob/main/Detection/Threat%20Hunting/CROWDSTRIKE_BSOD_scams/IOCS/malicious_ip.csv)
- [malicious_hashes.csv](https://github.com/mthcht/Purpleteam/blob/main/Detection/Threat%20Hunting/CROWDSTRIKE_BSOD_scams/IOCS/malicious_hashes.csv)
- [malicious_email.csv](https://github.com/mthcht/Purpleteam/blob/main/Detection/Threat%20Hunting/CROWDSTRIKE_BSOD_scams/IOCS/malicious_email.csv)
- [malicious_domains.csv](https://github.com/mthcht/Purpleteam/blob/main/Detection/Threat%20Hunting/CROWDSTRIKE_BSOD_scams/IOCS/malicious_domains.csv)
- [suspicious_file_name.csv](https://github.com/mthcht/Purpleteam/blob/main/Detection/Threat%20Hunting/CROWDSTRIKE_BSOD_scams/IOCS/suspicious_file_name.csv)
- [suspicious_file_path.csv](https://github.com/mthcht/Purpleteam/blob/main/Detection/Threat%20Hunting/CROWDSTRIKE_BSOD_scams/IOCS/suspicious_file_path.csv)
## Others
