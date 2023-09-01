$TTL    86400
hostdomain286.		IN  SOA		ns1.dnsDomain286. dns.inkisaverb.com. (
0000000001		; Serial No
10800			; Refresh
3600			; Retry
604800			; Expire
1800 )			; Minimum TTL

$ORIGIN hostdomain286.
; Nameserver Defaults
@		IN  NS		ns1.dnsDomain286.
@		IN  NS		ns2.dnsDomain286.

; Root Site Defaults
@		IN  A		hostipv4286
@		IN  AAAA	hostipv6286
;; End Root Site Defaults

; Hostname Record Defaults
i.hostdomain286.		IN  A		hostipv4286
i.hostdomain286.		IN  AAAA	hostipv6286

; Aliase Default
*.hostdomain286.		IN  CNAME	hostdomain286.

; Text Record Defaults
