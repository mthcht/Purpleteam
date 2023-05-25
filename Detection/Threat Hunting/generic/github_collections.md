## Hunt for Github access
ref: https://twitter.com/mthcht/status/1654214456149262337?s=20

As multiple other malwares used these sites for collection or exfiltration, you should have a detection rule on proxy logs for raw content access and POST requests on Pastebin-like sites.

Raw content access with Github:
- `*http://raw.githubusercontent.com*`
- `*http://codeload.github.com*`
- `*http://objects.githubusercontent.com/github-production-release-asset-*`
- `*/github.com*.exe?raw=true*`
