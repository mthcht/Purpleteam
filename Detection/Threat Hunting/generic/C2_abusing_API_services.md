# C2 Hiding in plain sight
*also published on https://mthcht.medium.com/c2-hiding-in-plain-sight-7a83963b9344*
*Understanding your environment with the applications used and allowed will enhances the effectiveness of your hunt here*

## Telegram API usage
  - C2 projects: 
    - https://github.com/3ct0s/disctopia-c2
    - https://github.com/timebotdon/telegram-c2agent
    - https://github.com/SpenserCai/DRat
    - https://github.com/kensh1ro/NativeTeleBackdoor
    - https://github.com/Lemonada/teleBrat
    - https://github.com/woj-ciech/Social-media-c2
    - https://github.com/machine1337/TelegramRAT
    - https://github.com/1N73LL1G3NC3x/Nightmangle
    - https://github.com/itaymigdal/Poshito
  - API detection: 
    - Requests to `https://api.telegram.org/bot*`

## Twitter API usage
  - C2 projects:
    - https://github.com/slaeryan/LARRYCHATTER
    - https://github.com/PaulSec/twittor
    - https://github.com/woj-ciech/Social-media-c2
  - API detection: 
    - Requests to `https://api.twitter.com/1*`,`https://api.twitter.com/2*`,`https://upload.twitter.com/`,`https://api.twitter.com/oauth*` 
 
## Gmail API usage
  - C2 projects:
    - https://github.com/byt3bl33d3r/gcat
    - https://github.com/machine1337/gmailc2
    - https://github.com/reveng007/SharpGmailC2
    - https://github.com/rschwass/PSGSHELL
    - https://github.com/shanefarris/GmailBackdoor
  - API detection: 
    - Requests to `https://www.googleapis.com/gmail/*`, `https://www.googleapis.com/auth/*`
 
## Slack API usage
  - C2 projects:
    - https://github.com/Coalfire-Research/Slackor
    - https://github.com/bkup/SlackShell
    - https://github.com/praetorian-inc/slack-c2bot
    - https://github.com/j3ssie/c2s
    - https://github.com/herwonowr/slackhell
    - https://github.com/Yihsiwei/slack-c2-golang
  - API detection: 
    - Requests to `https://slack.com/api/*` 
  
## Discord API usage
  - C2 projects:
    - https://github.com/MythicC2Profiles/discord
    - https://github.com/3ct0s/disctopia-c2
    - https://github.com/emmaunel/DiscordGo
    - https://github.com/crawl3r/DaaC2
    - https://github.com/th3r4ven/Bifrost
    - https://github.com/kensh1ro/Willie-C2
    - https://github.com/codeuk/discord-rat
    - https://github.com/Vczz0/Cerberos-C2
    - https://github.com/3NailsInfoSec/DCVC2
    - https://github.com/hoaan1995/ZER0BOT
    - https://github.com/Jeff53978/Python-Trojan
  - API detection: 
    - Requests to `https://discord.com/api/*` 
  
## Google Sheet/Google Drive API usage
  - C2 projects:
    - https://github.com/looCiprian/GC2-sheet 
    - https://github.com/a-rey/google_RAT
    - https://github.com/SpiderLabs/DoHC2
  - API detection: 
    - Requests to `https://sheets.googleapis.com/*`,`https://www.googleapis.com/drive/*` 

## Google Calendar
- C2 projects:
  - https://github.com/MrSaighnal/GCR-Google-Calendar-RAT
- API detection:
  - Requests to `https://www.googleapis.com/auth/calendar*`

## Github API usage
  - C2 projects:
    - https://github.com/3ct0s/disctopia-c2
    - https://github.com/TheD1rkMtr/GithubC2
  - API detection: 
    - Requests to `https://api.github.com/*` 

## Youtube API usage
  - C2 projects:
    - https://github.com/latortuga71/YoutubeAsAC2 
    - https://github.com/woj-ciech/Social-media-c2
    - https://github.com/ricardojoserf/SharpCovertTube
  - API detection: 
    - Requests to `https://www.googleapis.com/youtube/*`

## Pastebin API usage
  - C2 projects:
    - https://github.com/3ndG4me/AgentSmith
    - https://github.com/PeterEdtu/Pastebad-Reverse-Shell (pastebin.fr)
  - API detection: 
    - Requests to `https://pastebin.com/api/api_post.php`,`https://pastebin.com/api/*`

## Reddit API usage
  - C2 projects:
    - https://github.com/kleiton0x00/RedditC2
    - https://github.com/thrasr/reddit-c2
  - API detection: 
    - Requests to `https://www.reddit.com/api/*`

## Dropbox API usage
  - C2 projects:
    - https://github.com/Arno0x/DBC2
  - API detection:
    - Requests to `https://api.dropboxapi.com/*` 

## Instagram API usage
  - C2 projects:
    - https://github.com/woj-ciech/Social-media-c2
  - API detection: 
    - Requests to `https://api.instagram.com/oauth/*`,`https://graph.instagram.com/*`

## Zoom API usage
  - C2 projects:
    - https://github.com/0xEr3bus/ShadowForgeC2
  - API detection:
    - Requests to `https://api.zoom.us/v2/chat/users/me/*`  

## Virustotal API usage
  - C2 projects:
    - https://github.com/RATandC2/VirusTotalC2
    - https://github.com/D1rkMtr/VirusTotalC2 (the repo does not exist anymore and the github username changed from D1rkMtr to TheD1rkMtr)
    - https://github.com/g0h4n/REC2
    - https://github.com/samuelriesz/SharpHungarian
  - API detection: 
    - Requests to `https://www.virustotal.com/api/v3/*/comments`, `https://www.virustotal.com/api/v2/*/comments`

## Zulip API usage
  - C2 projects:
    - https://github.com/n1k7l4i/goZulipC2
  - API detection:
    - Requests to:
      - `https://*.zulipchat.com/api/v1/messages*` 
      - `https://*.zulipchat.com/api/v1/user_uploads*`
      - `https://*.zulipchat.com/api/v1/users/me/subscriptions*`
      - `https://*.zulipchat.com/api/v1/get_stream_id?stream=*`

## Notion API usage
 - C2 projects:
   - https://github.com/mttaggart/OffensiveNotion
 - API detection:
   -  Requests to `https://api.notion.com*`
  
## Matrix API usage
- C2 projects:
  - https://github.com/n1k7l4i/goMatrixC2/
- API detection:
  - POST Requests to `https://matrix.org/_matrix/client/r0/rooms/*/send/m.room.message`
  - GET Requests to `https://matrix.org/_matrix/client/r0/rooms/*/messages`

## OPENAI API usage
- C2 projects:
  - https://github.com/spartan-conseil/ratchatpt
- API detection:
  - POST & GET Requests to `https://api.openai.com/v1/files*`
  - POST Requests to `https://api.openai.com/v1/files/*`
  - GET Requests to `https://api.openai.com/v1/files/*/content*`

