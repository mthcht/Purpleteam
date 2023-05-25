## Hunt for Github access
ref: https://twitter.com/mthcht/status/1654062820349165574

As multiple other malwares used these sites for collection or exfiltration, you should have a detection rule on proxy logs for raw content access and POST requests on Pastebin-like sites.

Raw content access and exfiltration with pastebin:
  - `*http://pastebin.com*/raw/*` 
  - `*http://pastebin.com*/rw/*`
  - `*http://pastebin.com*api/api_post.php*`
