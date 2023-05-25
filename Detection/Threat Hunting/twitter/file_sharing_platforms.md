## Used by Ransomware actors

ref: https://twitter.com/mthcht/status/1660953897622544384?s=20

Interesting observation on the file-sharing platform preferences derived from the negotiations chats with LockBit victims. They used: http://temp.sh, http://file.io, http://sendspace.com, http://anonfiles.com, http://transfert-my-files.com, http://tempsend.com, http://transfer.sh and http://bashupload.com

Detect data collection and exfiltration on these types of platforms:

### Exfiltration:

POST requests to:
- `https://temp.sh/upload`
- `https://file.io/?title=*`
- `https://*.sendspace.com/upload`
- `https://api.anonfiles.com/upload`
- `https://transfert-my-files.com/inc/upload.php`
- `https://tempsend.com/send`
- `transfer.sh`
- `bashupload.com`

### Collection:

GET requests to:
- `https://temp.sh/*/*`
- `https://file.io/*`
- `https://www.sendspace.com/file/*`
- `https://anonfiles.com/*/*`
- `https://transfert-my-files.com/files/*`
- `https://tempsend.com/*`
- `https://transfer.sh/*`
- `https://bashupload.com/*`

---
