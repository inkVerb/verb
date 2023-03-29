# web https

## This enables or disables https forwarding for a hosted domain or subdomain on the webserver
- This is available on LAMP, LEMP, and LAEMP servers

## Usage
- `ink web https -y/n -d [ somedomain.tld ]`

- `ink web https -y -d inkisaverb.com`
  - `sed` replaces options in `sites-available/inkisaverb.com.conf`
  - For LAMP, adds or removes an Apache `<VirtualHost *:80>` statement using:
    - `RewriteCond` - `RewriteRule`
  - For LAEMP/LEMP, adds or removes an Nginx `server` statement using:
    - `listen` - `server_name` - `return 301`
