## Search for HTTP requests without domain names
ref: https://twitter.com/mthcht/status/1629943703476289536?s=20

```
  `myproxylogs` url=*
  NOT (dest_ip IN ("10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"))
  | regex url =^(http|https|tunnel)\:\/\/\d*\.\d*\.\d*\.\d*\/[\W|\w]
  | stats values(url)
    earliest(_time) as firsttime
    latest(_time) as lasttime
    values(action)
    values(index)
    values(sourcetype)
    values(http_user_agent)
    values(src_user)
    values(dest_ip)
    values(dest_port)
    values(http_method)
    count by src_ip
  | rename values(*) as *
  | convert ctime(*time)
```

- `myproxylogs` is a macro to search in my proxy logs, use your own search
- `/[\W|\w]` in my regex to match the HTTP requests without domain names getting some files and not just the IP address 
- sometimes it could be more relevant to aggregate by src_user instead of src_ip, if src_user is always filled (can have VIP src_ip addresses with lots of different users)
