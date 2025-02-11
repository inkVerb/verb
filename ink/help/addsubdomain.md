# add subdomain

## This adds a subdomain to a hosted domain to the webserver
- This will also adds entries to the main domain in the DNS zone file and SSL cert entries
  - Running this will *not* create a new domain record, but add to existing ones
  - This will *not* add OpenDKIM keys nor create a new email domain
- This also creates Apache/Nginx .conf files and folders at `www/domains/` linked to `www/html/`
- This requires that `add domain` already be run for the parent domain


## Usage
- `ink add subdomain -s [ subdomain ] -d [ somedomain.tld ]`

- `ink add subdomain -s subdom -d inkisaverb.com`
  - Creates the domain folder `www/domains/subdom.inkisaverb.com` & makes it live at `www/html/subdom.inkisaverb.com`
  - Creates a hosted domain config for the webserver (whether for Nginx, Apache, or Nginx-Apache reverse proxy)
    - Subdomains will not forward http to https by default
    - This can always be changed with `web https` commands
  - Adds entries to:
    - DNS Zone file for the parent domain
    - SSL/Letsencrypt subdomain to parent domain config, needed *before* the SSL certs are obtained
      - All subdomains will appear in the same SSL cert, regardless of the `-a` optional flag used in `ink add domain`
  - Does *not* add:
    - OpenDKIM records and keys
    - Email domain in PostfixAdmin
    - Additional framework to add subdomains via `ink add subdomain` to what is created here
