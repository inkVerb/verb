# web read

## This enables or disables public access to file lists for a hosted Apache domain or subdomain on the webserver
- This is only allowed on LAMP or LAEMP servers, not LEMP
- This uses `.htaccess` inside the web folder

## Usage
- `ink web read -y/n -d [ somedomain.tld ]`

- `ink web read -y -d inkisaverb.com`
  - `echo` adds and `sed` removes Apache options in `www/html/inkisaverb.com/`
  - Adds or removes:
    - `+Indexes`
    - `IndexOptions +FancyIndexing`
    - `allow from all`
    - `deny from all`
