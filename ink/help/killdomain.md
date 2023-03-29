# kill domain

## This removes a hosted domain to the webserver
- This will remove the Apache/Nginx .conf files and remove the link to the hosted folder
- This ***normally*** *will not* remove web folders or the domain SSL, DNS, and OpenDKIM framework
  - Unless using the `-p` flag, then these will also be purged:
    - Web folder at: `www/domains`
    - DNS zone files
    - Letsencrypt SSL entries and certificates
    - OpenDKIM keys and entries
    - Mail domain and mail folder
- *Do not* use the `-p` flag if you need to keep the domain framework, such as for subdomains

## Usage
- `ink kill domain -d [ somedomain.tld ]`
- `ink kill domain -d [ somedomain.tld ] -p` (To delete the web folder)
- `ink kill domain -d inkisaverb.com`
  - Removes a hosted domain config for the webserver (whether for Nginx, Apache, or Nginx-Apache reverse proxy)
  - Removes the web folder link to `www/html/inkisaverb.com`
  - Leaves in tact:
    - DNS Zone files
    - SSL/Letsencrypt configs
    - OpenDKIM records and keys
    - Email domain in PostfixAdmin
    - Framework to use/add subdomains via `add subdomain`
    - Web folder at `www/domains/inkisaverb.com`
    - Mail domain inkisaverb.com in the mail database
    - Mail folder at `vmail/inkisaverb.com`
- `ink kill domain -d inkisaverb.com -p`
  - Removes a hosted domain config for the webserver (whether for Nginx, Apache, or Nginx-Apache reverse proxy)
  - Removes:
    - DNS Zone files
    - SSL/Letsencrypt configs
    - OpenDKIM records and keys
    - Email domain in PostfixAdmin
    - Framework to use/add subdomains via `add subdomain`
    - Web folder at `www/domains/inkisaverb.com`
    - Folder link to `www/html/inkisaverb.com`
    - Mail domain inkisaverb.com in the mail database
    - Mail folder at `vmail/inkisaverb.com`
