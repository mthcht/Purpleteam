# HTML Smuggling

## From a real phishing attempt (BASE64 + AES):

### Scenario:
ref: https://twitter.com/mthcht/status/1664272429169139712

The user received a phishing email requesting a transfer and included a shortened URL as a means to access the accompanying documents, the link redirect to `hidrive.com` hosting an html file:


![2023-06-01 14_52_54-HiDrive Share_ Send large files free of charge](https://github.com/mthcht/Purpleteam/assets/75267080/f7242815-7939-441a-8b25-83d6a711ddbb)

The user download the file and open it.

### Content of the html file:
```javascript
<script>
var myvar1 = 'base64_encoded_string'; var myvar2 = 'base64_encoded_string';myvar3 = ""
</script>
<script>
var myvar4 = atob(myvar1)
var myvar5 = atob(myvar2)
document.write(myvar4)
document.write(myvar5)
```

the content of myvar1 and myvar2 is encoded in base64 and decoded by atob when opening the html file, when decoded we get:

myvar1 content:
```javascript
<script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js"></script>
<script>var key = 'mysecretkey'; 
key = CryptoJS.enc.Utf8.parse(key); 
var decrypted =  CryptoJS.AES.decrypt('encrypted1', key, {mode: CryptoJS.mode.ECB }); 
document.write(decrypted.toString(CryptoJS.enc.Utf8));</script>
```

myvar2 content:
```javascript
'encrypted2', key, {mode: CryptoJS.mode.ECB }); 
document.write(decrypted.toString(CryptoJS.enc.Utf8));</script>
```
*i replaced the encrypted data with 'encrypted1 and 'encrypted2'*

You can see that the decryption key is embedded within the same HTML file.

When the HTML file is opened in a browser, the encoded content is decoded using base64, and the encrypted AES content is decrypted using the embedded decryption key.
This allows the attacker to bypass detections and execute their malicious code with the victim's browser.

## Detection

### user is redirected to `hidrive.com`
  - GET request to `https://get.hidrive.com/i/*`

### downloading PAYMENTS.html from `hidrive.com`
  - GET request to `https://get.hidrive.com/api/*/file/*`
  - The file is saved and Sysmon EID 15 will trigger (as suggested by [@johnk3r](https://twitter.com/mthcht/status/1664294705557823489)):
    - File stream created:
      ```
      UtcTime: 2023-06-01 15:26:23.877
      ProcessGuid: {6ac0160e-b889-6478-ffae-000000000300}
      ProcessId: 10036
      Image: C:\Program Files\Mozilla Firefox\firefox.exe
      TargetFilename: C:\Users\mthcht\Downloads\PAYMENTS.html:Zone.Identifier
      CreationUtcTime: 2023-06-01 15:26:21.411
      Hash: SHA1=ANONYMiZED,MD5=ANONYMiZED,SHA256=ANONYMiZED,IMPHASH=00000000000000000000000000000000
      Contents: [ZoneTransfer]  ZoneId=3  ReferrerUrl=https://get.hidrive.com/i/ANONYMiZED  HostUrl=https://get.hidrive.com/api/ANONYMiZED/file/ANONYMiZED
      User: WIN10\mthcht
      ```
    - In Sysmon EID 15 look for TargetFilename ending with `*.html:Zone.Identifier` and ZoneID=3

### manually opening a downloaded PAYMENTS.html directly from explorer:
  - **Registry**:
    - Sysmon EID 12 & 13 with process `explorer.exe` and target registry key containing `*\\Explorer\\*.html*`
  - **CommandLines** (Security EID 4688 or Sysmon EID 1): 
    - observed with default browser msedge: `*\\Microsoft\\Edge\\Application\\msedge.exe" --single-argument *\\Users\\*\\Download\\PAYMENTS.html`
    - observed with chrome: `*\\Google\\Chrome\\Application\\chrome.exe" --single-argument *\\Users\\*\\Download\\PAYMENTS.html`
    - observed with firefox: `*\\Mozilla Firefox\\firefox.exe" -osint -url *\\Users\\*\Download\\PAYMENTS.html`
    - observed with Internet Explorer: `*\\Internet Explorer\\iexplore.exe" *\\Users\\*\\Download\\PAYMENTS.html`

## Consider other delivery methods inside archives:

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
    
### manually opening a downloaded PAYMENTS.html from an archive with default explorer:
  - **CommandLines** from parent process `*\\explorer.exe` (Security EID 4688 or Sysmon EID 1) :
    - [chrome] with child process `*\\chrome.exe*` : `*\\Google\\Chrome\\Application\\chrome.exe" --single-argument *\\Users\\*\\AppData\\Local\\Temp\\Temp1_*.zip\\PAYMENTS.html`
    - [Internet Explorer] with child process `*\\iexplorer.exe` : `*\\Internet Explorer\\iexplore.exe" *\\Users\\*\\AppData\\Local\\Temp\\Temp1_*.zip\\PAYMENTS.html`
    - [edge] with child process `*\\msedge.exe` : `*\\Microsoft\\Edge\\Application\\msedge.exe" --single-argument *\\Users\\*\\AppData\\Local\\Temp\\Temp1_*.zip\\PAYMENTS.html`
    - [firefox] with child process `*\\firefox.exe` : `*\\Mozilla Firefox\\firefox.exe" -osint -url *\\Users\\*\\AppData\\Local\\Temp\\Temp1_*.zip\\PAYMENTS.html`
    
### manually opening a downloaded PAYMENTS.html from an archive with winzip (very crappy software btw):
  - **Registry**:
    - Sysmon EID 12 & 13 with process `winzpi64.exe` and target registry key containing `*\\Explorer\\*.html*`
  - **File created** and **File creation time changed** when opening the html page from the archive (Sysmon EID 11 + EID 2):
    - from process `*\\winzip64.exe` and target file name `*\\Users\\*\\AppData\\Local\\Temp\\wz*\\PAYMENTS.html`
  - **CommandLines** from parent process `*\\winzip64.exe` (Security EID 4688 or Sysmon EID 1) :
    - [chrome] with child process `*\\chrome.exe*` : `*\\Google\\Chrome\\Application\\chrome.exe" --single-argument *\\Users\\*\\AppData\\Local\\Temp\\wz*\\PAYMENTS.html`
    - [Internet Explorer] with child process `*\\iexplorer.exe` : `*\\Internet Explorer\\iexplore.exe" *\\Users\\*\\AppData\\Local\\Temp\\wz*\\PAYMENTS.html`
    - [edge] with child process `*\\msedge.exe` : `*\\Microsoft\\Edge\\Application\\msedge.exe" --single-argument *\\Users\\*\\AppData\\Local\\Temp\\wz*\\PAYMENTS.html`
    - [firefox] with child process `*\\firefox.exe` : `*\\Mozilla Firefox\\firefox.exe" -osint -url *\\Users\\*\\AppData\\Local\\Temp\\wz*\\PAYMENTS.html`
  - **File deleted** when closing the opened html page from the browser (Sysmon EID 26):
    - from process `*\\winzip64.exe` and target file name `*\\Users\\*\\AppData\\Local\\Temp\\wz*\\PAYMENTS.html`
    

- If it's the first time the user open an .html file you will also see:
    - Registry: Sysmon EID 12 & 13 with process `Openwith.exe` and target registry key containing `*\\Explorer\\*.html`
    - Commandline: Sysmon EID 1 or Security EID 4688 with parent process `Openwith.exe`, your browser as a child process and the commandlines i gave from each browser

### Detection summary
  - The detection tips mentioned above are applicable to your threat hunting sessions. However, instead of focusing specifically on detecting my phishing example `PAYMENTS.html` file, broaden your scope by replacing it with `*.html`. This modification allows you to gather a comprehensive summary of all HTML files locally opened by users in your environment.
  - You can remove the `\\Users\\*\\Download\\` portion from the file path. This adjustment enables you to capture HTML files from various locations, such as external drives, default download folders, temporary directories, and other potential locations where users may interact with such files and progressively adjust your query to include relevant file paths commonly associated with phishing attempts if necessary.
