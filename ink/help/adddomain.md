# add domain

## This adds a hosted domain to the webserver
- This will also create DNS zone, email, DKIM, and SSL cert entries the first time it is run
  - Running this for a subdomain will create these for the subdomain, as if it is the root domain
- Typical usage is to run this for the domain, then `add subdomain` for subdomains under this hierarchy


## Usage
- `ink add domain -d [ somedomain.tld ] -a [ multi/wild - auto SSL cert option ]`

- `ink add domain -d inkisaverb.com`
  - Creates the domain folder `www/domains/inkisaverb.com` & makes it live at `www/html/inkisaverb.com`
  - Creates a hosted domain config for the webserver (whether for Nginx, Apache, or Nginx-Apache reverse proxy)
  - Confirms the existence of:
    - DNS Zone files
    - SSL/Letsencrypt configs, needed *before* the SSL certs are obtained
    - OpenDKIM records and keys
    - Email domain in PostfixAdmin
    - Framework to add subdomains via `add subdomain`
- `ink add domain -d inkisaverb.com -a multi`
  - Does everything same as above, but automatically installs a Letsencrypt multi certs for only this domain
    - This is achieved by creating a self-destructing cron task called digdomain-DOMAIN, which runs "donjon/digdomain.sh inkisaverb.com multi" every 5 minutes
  - `ink cert` will not be able to nor need to run for this domain after using this option, unless running `ink cert undo` first
- `ink add domain -d inkisaverb.com -a wild`
  - Does everything same as above, but automatically installs a Certbot wildcard certs for this domain
    - This is achieved by creating a self-destructing cron task called digdomain-DOMAIN, which runs "donjon/digdomain.sh inkisaverb.com wild" every 5 minutes
  - `ink cert` will not be able to nor need to run for this domain after using this option, unless running `ink cert undo` first
