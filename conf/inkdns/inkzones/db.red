$TTL    86400
hostdomain286.		IN  SOA		hostURI286. dns.inkisaverb.com. (
0000000001		; Serial No
10800			; Refresh
3600			; Retry
604800			; Expire
1800 )			; Minimum TTL

$ORIGIN hostdomain286.
; Nameserver Defaults
@		IN  NS		ns1.DNsdnsDomainAIN286.
@		IN  NS		ns2.DNsdnsDomainAIN286.

; Root Site Defaults
@		IN  A		hostipv4286
@		IN  AAAA	hostipv6286
;; End Root Site Defaults

; Hostname Record Defaults
r.hostdomain286.		IN  A		hostipv4286
r.hostdomain286.		IN  AAAA	hostipv6286

; Aliase Default
*.hostdomain286.		IN  CNAME	hostdomain286.

; Text Record Defaults
