# web vipcgi

## This enables or disables CGI for a v.YOURNAME.verb.vip/cgi
- This is only allowed on LAMP or LAEMP servers, not LEMP
- The FTP folder `vip/cgi` will be publically available at `v.YOURNAME.verb.vip/cgi`

## Usage
- `ink web vipcgi -y/n`

- `ink web vipcgi -y`
  - `sed` replaces Apache options in `httpd/sites-available/v.YOURNAME.verb.vip.conf`
  - Adds or removes:
    - `Execcgi`
    - `AddHandler cgi-script .cgi`
  - Creates a symlink
    - From `www/vip/cgi`
    - To `www/html/vip.v/cgi`
