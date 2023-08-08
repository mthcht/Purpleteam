## Hunt for Github access
ref: https://twitter.com/mthcht/status/1654214456149262337?s=20

As multiple other malwares used github for collection or exfiltration, we should hunt for github raw content access:

Raw content access with Github:
- `*https://raw.githubusercontent.com*`
- `*https://codeload.github.com*`
- `*https://objects.githubusercontent.com/github-production-release-asset-*`
- `*/github.com*.exe?raw=true*`
- `*https://gist.githubusercontent.com/*/*/raw/*`
