## Browser extensions detections

ref https://twitter.com/mthcht/status/1647370542867947520

### Firefox

On a windows machine, when a Firefox addon is installed, the following operations are observed by the Firefox.exe process:
- File creation: 
  - myaddon and myaddon.xpi in:
    - `C:\Users\*\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-esr\extensions\staged\`
  - addon GUID in : 
    - `C:\Users\*\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-esr\storage\default\moz-extension+++(myaddonGUID)*`
- Image loaded:
  - `C:\Program Files (x86)\Mozilla Firefox\xul.dll`
- Proxy logs: 
  - `http://addons.mozilla.org`
  - `http://addons.mozilla.org/firefox/downloads/file/*`
  - `url ending with ".xpi"`
- CLI installation if occured (check parent process):
   - CommandLine:  `firefox -install-global-extension *.xpi`
- Informations about extensions in extensions.json of the firefox user profile

I would look for any of these traces to find out when and how the addon was installed and if an incident occured.

---

### Chrome

When you install an addon on chrome, the following traces are observed:

#### Download process:
- chrome.exe load image BitsProxy.dll > svchost.exe loads bits*.dll > BITS download the addon and write logs in event logs "Microsoft-Windows-Bits-Client" in EID 59 & 60.

- URL requests: 
  - `http://edgedl[.]me.gvt1[.]com/edgedl/release2/chrome_component/*.crx3`   
  - `http://edgedl[.]me.gvt1[.]com/edgedl/chromewebstore/*.crx`
  - `https://clients2[.]google|.]com/service/update2/crx?*`
  - `https://clients2[.]googleusercontent[.]com/crx/blobs/*.crx`
  - any url ending with `.crx` or `.crx3` if not downloaded from the chromestore

It seems that chrome will download the extension in both crx and crx3 formats for backward compatibility...

- File creations:
  - BITS download completed, svchost.exe will write the crx3 file in `C:\Program Files\chrome_BITS_*\*.crx3`
  - chrome.exe will write:
    - `C:\Users\username\AppData\Local\Google\Chrome\User Data\Webstore Downloads\*.crx`
    - `C:\Users\username\AppData\Local\Temp\scoped_dir*\*.crx`
    - `C:\Users\username\AppData\Local\Temp\scoped_dir*\CRX_INSTALL\assets\EXTENSION_NAME\*`
    - `C:\Users\username\AppData\Local\Google\Chrome\User Data\Default\Extensions\EXTENSION_NAME\*`

- Registry:
  - When installing the crx extension the process chrome.exe will access `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\*\.crx\*`

- Image loaded by chrome.exe (these are not useful for detection because the dll files can be used for other stuffs in chrome):
  - `C:\Program Files\Google\Chrome\Application\*\chrome_elf.dll` (to install the addon)
  - `C:\Windows\System32\BitsProxy.dll` (to download the addon with BITS)

- CLI installation (if occured):
  - `...chrome.exe --enable-extensions --install-extension="*.crx"`
  - look for commandlines with `.crx` or `.crx3`

In `C:\Users\username\AppData\Local\Google\Chrome\User Data\Default\Extensions\` each folder represents a Chrome extension.

Check the extension folder creation date and the manifest.json in each folder to get details on the addon installed.
To get more information via the command line, we can examine Chrome's database files.
