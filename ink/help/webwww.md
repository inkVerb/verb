# web www

## This enables or disables 'www' subdomain forwarding for a hosted domain or subdomain on the webserver
- This is available on LAMP, LEMP, and LAEMP servers
- This uses .conf options in `sites-available/`
  - For LAMP & LAEMP servers it affects
    - Apache: `httpd/sites-available/`
  - For LEMP servers it affects
    - Nginx:  `nginx/sites-available/`
- This does not affect DNS records
- For example, this allows use of any subdomain for something like
  - www.example.tld
  - www.subdomain.example.tld
  - www.inkisaverb.com
  - www.subdomain.inkisaverb.com
- This may not be necessary because DNS records may already handle this for the primary domain, however they may not necessarily handle www for subdomains
- This is technically a legacy option because 'www' stopped being necessary around the year 2001

## Usage
- `ink web www -y/n -d [ somedomain.tld ]`

- `ink web www -y -d inkisaverb.com`
  - `sed` replaces options in `sites-available/inkisaverb.com.conf`
  - For Apache, adds or removes `ServerName www.inkisaverb.com` & `Redirect permanent`
  - For Nginx, adds or removes `server_name www.inkisaverb.com;` & `return 301`
