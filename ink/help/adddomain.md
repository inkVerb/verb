# add domain

## This adds a hosted domain to the webserver
- This will also create DNS zone, email, DKIM, and SSL cert entries the first time it is run
  - Running this for a subdomain will create these for the subdomain, as if it is the root domain
- Typical usage is to run this for the domain, then `add subdomain` for subdomains under this hierarchy


## Usage
- `ink add domain -d [ domain.tld ] -n|m|s|w ( auto SSL cert option ) -p ( park option)`

- `ink add domain -d inkisaverb.com`
  - Same as `ink add domain -d inkisaverb.com -n`
  - Creates the domain folder `www/domains/inkisaverb.com` & makes it live at `www/html/inkisaverb.com`
  - Creates a hosted domain config for the webserver (whether for Nginx, Apache, or Nginx-Apache reverse proxy)
  - Confirms the existence of:
    - DNS Zone files
    - SSL/Letsencrypt configs, needed *before* the SSL certs are obtained
    - OpenDKIM records and keys
    - Email domain in PostfixAdmin
    - Email subdomains: `mail.domain.tld`, `imap.domain.tld`, `smtp.domain.tld`, `pop3.domain.tld`, etc
    - Framework to add subdomains via `ink add subdomain`
  - To obtain certs, such as after adding subdomains, run `ink cert do
- `ink add domain -d inkisaverb.com -m`
  - Does everything same as above, but automatically installs Letsencrypt certs, but allows for multiple subdomains to be added to the same cert in the future
    - Meaning that that, if there are subdomains for this domain added before or after this, they will appear in this domain's SSL cert
    - Mail subdomain certs will automatically be included with this domain anyway
    - This is achieved by creating a self-destructing `cron` task called digdomain-DOMAIN, which runs `donjon/digdomain.sh inkisaverb.com multi` every 5 minutes
  - `ink cert` will not be able to nor need to run for this domain after using this option, unless running `ink cert undo` first
- `ink add domain -d inkisaverb.com -s`
  - Does everything same as above, but automatically installs Letsencrypt certs, but allows for multiple subdomains to be added to the same cert in the future
    - Meaning that that, if there are subdomains for this domain, they will not appear in this domain's SSL cert
    - Mail certs will not be included in this domain's cert
    - This is achieved by creating a self-destructing `cron` task called digdomain-DOMAIN, which runs `donjon/digdomain.sh inkisaverb.com multi` every 5 minutes
  - `ink cert` will not be able to nor need to run for this domain after using this option, unless running `ink cert undo` first
- `ink add domain -d inkisaverb.com -w`
  - Does everything same as above, but automatically installs Certbot wildcard certs for this domain
    - This is achieved by creating a self-destructing `cron` task called digdomain-DOMAIN, which runs `donjon/digdomain.sh inkisaverb.com wild` every 5 minutes
    - Only the domain and wildcard domain `*.inkisaverb.com` will be included in this cert, despite the fact that mail subdomains reside on the server
  - `ink cert` will not be able to nor need to run for this domain after using this option, unless running `ink cert undo` first
- `ink add domain -d inkisaverb.com -n|m|s|w -p`
  - Does whatever `-n`, `-m`, `-s` or `-w` flags would do
  - Parks the domain on this server
    - This creates all other settings normally done even without this flag
    - The domain can be entirely hosted on this server, even with email and SSL certificates
    - The `db.inkisaverb.com` zone file will move from `inkdns/zones/` to `inkdns/parked/`
    - If hosted on a different server, that `db.inkisaverb.com` file will need to be manually updated
    - Any changes for SSL certificates will need to be adjusted in `inkcert/cli-ini/cli.inkisaverb.com` on all affected servers so there is no conflict
    - Any sites should be properly de-activated in `webserver/sites-available/...`
