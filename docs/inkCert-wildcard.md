# inkCert wildcard (DNS-01) flow

Wildcard certs (`*.domain.tld` plus `domain.tld`) require Letsencrypt DNS-01.
HTTP-01 cannot prove a wildcard. inkCert-CB (`inkcertdocb` / `ink cert do -w`)
now does this without typing TXT records by hand.

## Where things live

- `conf/inkcert/` — ACME/Certbot material (cli-ini per domain, TSIG key, rfc2136.ini)
- `conf/inkdns/` — Bind zone **entries only** (db.* / nv.*). Never the ACME key.
- `/etc/letsencrypt/rfc2136.ini` — live Certbot RFC2136 credentials (symlink world via `/etc/inkcert/le`)
- `/opt/verb/conf/inkcert/inkcertbot.key` — TSIG key, generated **once**

The TSIG secret stays on the Verber (the Bind master). Slaves do not need it.
Letsencrypt queries ns1/ns2; those boxes only need the zone transfer of the
TXT that nsupdate just wrote on the master.

## Why this was stuck

1. `inkdnsinstall` created a TSIG key named `inkCertbotKey` in `/etc/named.conf`.
2. `inkdnsrefreshbind` generated a **new** key named `inkcert` on every refresh.
3. `inkcertinstall` wrote rfc2136.ini for `inkCertbotKey`.
4. Zone `update-policy` granted `inkcert.`, so Certbot's key was refused.
5. `inkcertreqcb` used `--nginx --preferred-challenges=dns`, which is interactive
   (prints a TXT and waits). The RFC2136 line was commented pending NS sync.

## What runs now

### One-time (install)

1. `inkdnsinstall` calls `inkcertsetdnskey`
   - `tsig-keygen -a HMAC-SHA512 inkCertbotKey` → `conf/inkcert/inkcertbot.key`
   - include that file from `/etc/named.conf`
   - write rfc2136.ini (127.0.0.1, HMAC-SHA512)
2. `inkdnsrefreshbind` **includes** that same key (never regenerates it)
   - each master zone: `notify yes; also-notify { ns1; ns2; };`
   - `update-policy { grant inkCertbotKey. name _acme-challenge.ZONE. TXT; ... }`

### Each wildcard cert (`inkcertdocb` / adddomain ... wild)

1. `inkcertreqcb` runs certbot **non-interactive** with DNS-01 hooks:
   - `--manual --preferred-challenges=dns`
   - `--manual-auth-hook donjon/inkcert-dns01-auth.sh`
   - `--manual-cleanup-hook donjon/inkcert-dns01-cleanup.sh`
   - RSA 2048 (same as `cli-ini` `rsa-key-size`)
2. Auth hook:
   - `nsupdate -k inkcertbot.key` adds `_acme-challenge.domain.tld` TXT on localhost
   - `inkdnsslaveacme` SSH to `ns1` and `ns2` (same Host aliases as `rinkadddomain`)
     and runs `rndc retransfer domain.tld` so the slaves AXFR immediately
   - poll `dig @ns1` / `@ns2` until the TXT is visible, then exit 0
3. Certbot tells Letsencrypt to check. LE queries the registrar NS (ns1/ns2).
4. Cleanup hook deletes that TXT value and retransfers slaves again.

No web server stop is required for DNS-01.

## Already-installed Verbers

```
/opt/verb/serfs/inkcertsetdnskey
/opt/verb/serfs/inkdnsrefreshbind
/opt/verb/serfs/inkcertdocb domain.tld r
```

`inkcertsetdnskey` is idempotent: it reuses `conf/inkcert/inkcertbot.key` if
present, otherwise lifts `inkCertbotKey` out of `/etc/named.conf` if that
one-liner is still there, otherwise generates a new key.

## Self-parking (`ink dns self`) is not required

That was the old workaround so you could paste the interactive TXT onto the
Verber's own NS. With RFC2136 + slave AXFR, ns1.inkisaverb.com / ns2.inkisaverb.com
are enough, which is the normal rink layout.

## Rink / NS servers

`rink/run/addvps` already:

- writes SSH Host `ns1` / `ns2` (verber: `rinklocalsetup` or `rinkupdatekeys`)
- `rinkadddomain` SSHs configs into `/srv/sns/NAME-TLD/domains/{served,parked}/`
- NS cron `*/15 * * * * inkdnsrefreshbind` rebuilds slave `named.conf`

`inkdnsslaveacme` uses that same SSH. It does **not** copy the TSIG secret
into `/srv/sns/...`. The slaves are type slave; they cannot accept nsupdate.
They only AXFR. Copying the secret to ns1/ns2 would widen the blast radius
and would not make Letsencrypt see the TXT any faster.

## RSA vs Ed

- Certificate keys: RSA 2048 (`--key-type rsa --rsa-key-size 2048`), matching cli-ini.
- TSIG: HMAC-SHA512 (symmetric MAC, not an elliptic curve key). This is what
  `inkdnsinstall` already chose; BIND RFC2136 expects HMAC, not an RSA/Ed key.
- Verber→NS SSH: `rinklocalsetup` already uses `ssh-keygen -t rsa`.
