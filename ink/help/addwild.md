# add wild

## This enables wildcard `*` hosting on a domain already added with `add domain`
- `*.domain.tld` does **not** include `domain.tld` in nginx or Apache
- Both names live in the **same** `sites-available/domain.tld.conf` (the adddomain template from `inst/webserver/{lamp,lemp,laemp}-conf`)
  - Apache: `ServerName domain.tld` plus `ServerAlias *.domain.tld`
  - Nginx: `server_name domain.tld *.domain.tld;`
- Adds DNS `*.domain.tld` A/AAAA (not a CNAME)
- Does not create a second .conf or a `www/domains/*` folder
- Required before `ink cert do -w` / `inkcertdocb`

## Usage
- `ink add wild -d [ domain.tld ]`

- `ink add wild -d inkisaverb.com`
  - Same as `./addwild inkisaverb.com`
  - Parent domain must already exist (`ink add domain -d inkisaverb.com`)
