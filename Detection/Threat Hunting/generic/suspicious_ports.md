## Hunting for suspicious ports activities

Using the list of suspicious ports: https://github.com/mthcht/awesome-lists/blob/main/Lists/suspicious_ports_list.csv

### Hunt with Splunk:

high confidence search:
```splunk
  `myfirewall` src_ip IN (192.168.0.0/16,10.0.0.0/8,172.16.0.0/12)
  NOT (dest_ip IN (192.168.0.0/16,10.0.0.0/8,172.16.0.0/12))
  | lookup suspicious_ports_list.csv dest_port OUTPUT metadata.comment as comment metadata.confidence as confidence
  | where confidence=high
  | stats values(index)
    values(sourcetype)
    values(vendor_product)
    earliest(_time) as firsttime
    latest(_time) as lasttime 
    values(action)
    values(dest_ip)
    values(dest_port)
    values(protocol)
    values(comment)
    values(confidence)
    count by src_ip 
  | rename values(*) as *
  | convert ctime(*time)
```

All results (threathunting)
```splunk
  `myfirewall` src_ip IN (192.168.0.0/16,10.0.0.0/8,172.16.0.0/12)
  NOT (dest_ip IN (192.168.0.0/16,10.0.0.0/8,172.16.0.0/12))
  | lookup suspicious_ports_list.csv dest_port OUTPUT metadata.comment as comment metadata.confidence as confidence
  | stats values(index)
    values(sourcetype)
    values(vendor_product)
    earliest(_time) as firsttime
    latest(_time) as lasttime 
    values(action)
    values(dest_ip)
    values(dest_port)
    values(protocol)
    count by src_ip confidence comment
  | rename values(*) as *
  | convert ctime(*time)
```

- `myfirewall` is a macro i use to search in my firewall logs (use your own search)

