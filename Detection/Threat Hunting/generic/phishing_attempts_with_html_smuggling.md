# HTML Smuggling

## Description 

## Schema 

## Detection

### manually opening a downloaded html file with msedge:
  - Registry:
    - Sysmon EID 12 & 13 with process `explorer.exe` and target registry key containing `*\Explorer\*.html*`
    - If it's the first time the user open an .html file you will also see:
      - Registry: Sysmon EID 12 & 13 with process `Openwith.exe` and target registry key containing `*\Explorer\*.html`
  - CommandLines: 
    - observed with default browser msedge.exe: `C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --single-argument C:\Users\mthcht\Download\PAYMENTS.html`
    - observed with chrome: ``
    - observed with firefox: `` 
