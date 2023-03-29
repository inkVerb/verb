# kill domainshell

## This destroys the management framework for a domain
- This destroys and removes OpenDKIM keys and entries in `/etc/opendkim/`
- This deletes cli.domain.tld.ini and siteinkcert.domain.tld files in `verb/conf/inkcert/cli-ini/`
- This deletes DNS db.domain.tld and nv.domain.tld zone files in `verb/conf/inkdns/zones/`, complete with mail records
- This deletes `mail` database domain entries and mail folders
- This will also notify the "Rink" nameserver that this server is no longer the master for the domain
- This *does not* remove Apache/Nginx configs at `sites-available/`
  - To remove an Apache/Nginx config, use `ink kill domain`

## Usage
- `ink kill domainshell -d [ somedomain.tld ]`
- `ink kill domainshell -d inkisaverb.com`
  - Files deleted:
    - `/etc/opendkim/keys/inkisaverb.com`
    - `verb/conf/inkcert/cli-ini/cli.inkisaverb.com.ini`
    - `verb/conf/inkcert/cli-ini/siteinkcert.inkisaverb.com`
    - `verb/conf/inkdns/zones/db.inkisaverb.com`
    - `verb/conf/inkdns/zones/nv.inkisaverb.com`
    - `vmail/inkisaverb.com/`
  - Entries removed:
    - `/etc/opendkim/keys/SigningTable`
    - `/etc/opendkim/keys/KeyTable`
    - `verb/conf/inkdns/zones/db.inkisaverb.com` (Mail records)
    - `inkisavereb.com` removed from `mail` database at `mail.domains` and `mail.alias`
    - DNS bind entries on remote nameserver
