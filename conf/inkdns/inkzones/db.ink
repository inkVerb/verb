$TTL    86400
inkURI286.		IN  SOA		ns1.dnsDomain286. dns.inkisaverb.com. (
0000000001		; Serial No
10800			; Refresh
3600			; Retry
604800			; Expire
1800 )			; Minimum TTL

$ORIGIN inkURI286.
; Nameserver Defaults
@		IN  NS		ns1.dnsDomain286.
@		IN  NS		ns2.dnsDomain286.
@		IN  CAA		0 issue "letsencrypt.org"

; Root Site Defaults
@		IN  A		hostipv4286
@		IN  AAAA	hostipv6286
;; End Root Site Defaults

; Site Record Defaults
i.inkURI286.		IN  A		hostipv4286
i.inkURI286.		IN  AAAA	hostipv6286

; Text Record Defaults
