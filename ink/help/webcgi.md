# web cgi

## This enables or disables CGI for a hosted Apache domain or subdomain on the webserver
- This is only allowed on LAMP or LAEMP servers, not LEMP

## Usage
- `ink web cgi -y/n -d [ somedomain.tld ]`

- `ink web cgi -y -d inkisaverb.com`
  - `sed` replaces Apache options in `httpd/sites-available/inkisaverb.com.conf`
  - Adds or removes:
    - `Execcgi`
    - `AddHandler cgi-script .cgi`
