# HTML Smuggling

## Description 

## Schema 

## Detection

Let's name our phishing html file `PAYMENTS.html`

### manually opening a downloaded PAYMENTS.html directly from explorer:
  - **Registry**:
    - Sysmon EID 12 & 13 with process `explorer.exe` and target registry key containing `*\\Explorer\\*.html*`
  - **CommandLines** (Security EID 4688 or Sysmon EID 1): 
    - observed with default browser msedge: `*\\Microsoft\\Edge\\Application\\msedge.exe" --single-argument *\\Users\\*\\Download\\PAYMENTS.html`
    - observed with chrome: `*\\Google\\Chrome\\Application\\chrome.exe" --single-argument *\\Users\\*\\Download\\PAYMENTS.html`
    - observed with firefox: `*\\Mozilla Firefox\\firefox.exe" -osint -url *\\Users\\*\Download\\PAYMENTS.html`
    - observed with Internet Explorer: `*\\Internet Explorer\\iexplore.exe" *\\Users\\*\\Download\\PAYMENTS.html`
    
    - If it's the first time the user open an .html file you will also see:
      - Registry: Sysmon EID 12 & 13 with process `Openwith.exe` and target registry key containing `*\\Explorer\\*.html`
      - Commandline: Sysmon EID 1 or Security EID 4688 with parent process `Openwith.exe`, your browser as a child process and the commandlines i gave from each browser
    
### manually opening a downloaded PAYMENTS.html from an archive with 7zip:
  - **File created** when opening the html page from the archive (Sysmon EID 11):
    - from process `*\\7zFM.exe` and target file name `*\\Users\\*\\AppData\\Local\\Temp\\7z*\\PAYMENTS.html`
  - **Registry**:
    - Sysmon EID 12 & 13 with process `7zFM.exe` and target registry key containing `*\\Explorer\\*.html*`
  - **CommandLines** from parent process `*\\7zFM.exe` (Security EID 4688 or Sysmon EID 1) :
    - [chrome] with child process `*\\chrome.exe*` : `*\\Google\\Chrome\\Application\\chrome.exe" --single-argument *\\Users\\*\\AppData\\Local\\Temp\\7z*\\PAYMENTS.html`  
    - [Internet Explorer] with child process `*\\iexplorer.exe` : `*\\Internet Explorer\\iexplore.exe" *\\Users\\*\\AppData\\Local\\Temp\\7z*\\PAYMENTS.html` 
    - [edge] with child process `*\\msedge.exe` : `*\\Microsoft\\Edge\\Application\\msedge.exe" --single-argument *\\Users\\*\\AppData\\Local\\Temp\\7z*\\PAYMENTS.html`
    - [firefox] with child process `*\\firefox.exe` : `*\\Mozilla Firefox\\firefox.exe" -osint -url *\\Users\\*\\AppData\\Local\\Temp\\7z*\\PAYMENTS.html`
    
  - **File deleted** when closing the opened html page from the browser (Sysmon EID 26):
    - from process `*\\7zFM.exe` and target file name `*\\Users\\*\\AppData\\Local\\Temp\\7z*\\PAYMENTS.html`
    
  - If it's the first time the user open an .html file you will also see:
      - Registry: Sysmon EID 12 & 13 with process `Openwith.exe` and target registry key containing `*\\Explorer\\*.html`
      - Commandline: Sysmon EID 1 or Security EID 4688 with parent process `Openwith.exe`, your browser as a child process and the commandlines i gave from each browser

### manually opening a downloaded PAYMENTS.html from an archive with default explorer:
  - **CommandLines** from parent process `*\\explorer.exe` (Security EID 4688 or Sysmon EID 1) :
    - [chrome] with child process `*\\chrome.exe*` : `*\\Google\\Chrome\\Application\\chrome.exe" --single-argument *\\Users\\*\\AppData\\Local\\Temp\\Temp1_*.zip\\PAYMENTS.html`
    - [Internet Explorer] with child process `*\\iexplorer.exe` : `*\\Internet Explorer\\iexplore.exe" *\\Users\\*\\AppData\\Local\\Temp\\Temp1_*.zip\\PAYMENTS.html`
    - [edge] with child process `*\\msedge.exe` : `*\\Microsoft\\Edge\\Application\\msedge.exe" --single-argument *\\Users\\*\\AppData\\Local\\Temp\\Temp1_*.zip\\PAYMENTS.html`
    - [firefox] with child process `*\\firefox.exe` : `*\\Mozilla Firefox\\firefox.exe" -osint -url *\\Users\\*\\AppData\\Local\\Temp\\Temp1_*.zip\\PAYMENTS.html`
    
  - If it's the first time the user open an .html file you will also see:
      - Registry: Sysmon EID 12 & 13 with process `Openwith.exe` and target registry key containing `*\\Explorer\\*.html`
      - Commandline: Sysmon EID 1 or Security EID 4688 with parent process `Openwith.exe`, your browser as a child process and the commandlines i gave from each browser
