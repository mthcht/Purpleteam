## Detect phishing attempt and exploitations with canary tokens and callback urls
ref: https://twitter.com/mthcht/status/1647976012901232640?s=20

Canary tokens and callback URL services can aid in intrusion detection/testing, but are also exploited by threat actors for data exfiltration or payload confirmation.

Monitor URL access to known free public canary services, default urls such as:
  - `*//canarytokens.com/static/*`
  - `*.whiteclouddrive.com*`
  - `*//webhook.site/*`
  - `*.free.beeceptor.com/*`
  
Although threat actors can use any servers for this, at least monitoring known public services allows us to detect a portion of them.
False positive rate is low and should be easily reducible especially when these public services are not being used for your environment.
