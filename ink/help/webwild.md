# web wild

## This enables or disables subdomain wildcard forwarding for a hosted domain or subdomain on the webserver
- This is available on LAMP, LEMP, and LAEMP servers
- This uses .conf options in `sites-available/`
  - For LAEMP servers it affects both site .conf files
    - Apache: `httpd/sites-available/`
    - Nginx:  `nginx/sites-available/`
- This does not affect DNS records
- This may be useful for something like WordPress Multisite using subdomains
- For example, this allows use of any subdomain for something like
  - *.example.tld
  - *.subdomain.example.tld
  - *.inkisaverb.com
  - *.subdomain.inkisaverb.com

## Usage
- `ink web wild -y/n -d [ somedomain.tld ]`

- `ink web wild -y -d inkisaverb.com`
  - `sed` replaces options in `httpd`or`nginx` `/` `sites-available/inkisaverb.com.conf`
  - For Apache, adds or removes `ServerAlias *.inkisaverb.com`
  - For Nginx, adds or removes `server_name *.inkisaverb.com;`
