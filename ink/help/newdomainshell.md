# new domainshell

## This creates a new management framework for a domain
- This adds OpenDKIM keys and entries in `/etc/opendkim/`
- This creates cli.domain.tld.ini and siteinkcert.domain.tld files in `verb/conf/inkcert/cli-ini/`
- This creates DNS db.domain.tld and nv.domain.tld zone files in `verb/conf/inkdns/zones/`, complete with mail records
- This makes `mail` database entries, then mail folders will be created automatically when they are used
- This will also manage subdomains added with `ink add subdomain`
- This will also notify the "Rink" nameserver that this server is the master for the domain
- This *does not* create Apache/Nginx configs at `sites-available/`
- This *should not* be used for subdomains unless that subdomain needs its own indepeendent management framework
- This is automatically handled by `ink add domain`, but may be useful if the web admin needs to tweak the DNS Zone file before a domain goes live

## Usage
- `ink new domainshell -d [ somedomain.tld ]`
- `ink new domainshell -d inkisaverb.com`
  - Files created:
    - `/etc/opendkim/keys/inkisaverb.com`
    - `verb/conf/inkcert/cli-ini/cli.inkisaverb.com.ini`
    - `verb/conf/inkcert/cli-ini/siteinkcert.inkisaverb.com`
    - `verb/conf/inkdns/zones/db.inkisaverb.com`
    - `verb/conf/inkdns/zones/nv.inkisaverb.com`
    - `vmail/inkisaverb.com/` will be created automatically the first time Postfix uses this domain
  - Entries made:
    - `/etc/opendkim/keys/SigningTable`
    - `/etc/opendkim/keys/KeyTable`
    - `verb/conf/inkdns/zones/db.inkisaverb.com` (Mail records)
    - `inkisavereb.com` added to `mail` database at `mail.domains` and `mail.alias`
    - DNS bind entries on remote nameserver
