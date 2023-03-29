# new vipsub

## This creates new subdomain for the NEWSUB.YOURNAME.verb.vip
- The web folder will be in `vip/_subs.vip/`
  - This folder is available to users created with `ink new ftp -t vip`
- This will add necessary entries for DNS records and the list used by `ink cert do -m` flag
- This *will not* get new SSL certs if `ink cert do` used the `-s` or `-m` flag
  - If `ink cert do -w` was used for the .verb.vip domain, these will automatically be applied

## Usage
- `ink new vipsub -s [ subdomain ]`
- `ink new vipsub -s subme`
  - Creates a folder `vip/_subs.vip/subme`
    - This is available to users created with `ink new ftp -t vip`
  - Creates .conf files in `sites-available` and enables them for Apache/Nginx
  - Adds necessary DNS zone entries for the YOURNAME.verb.vip zone file at `conf/inkdns/inkzones/`
  - Adds a Letsencrypt domain entry to `conf/inkcert/cli-ini/`
  - Creates the live URL subme.YOURNAME.verb.vip
  - Will *only* have SSL  certs applied if verb tld certs were attained using `ink cert do -a -w`
    - Otherwise obtain new SSL certs with `ink cert do -s|m -d YOURNAME.verb.vip`, as was used at server setup
      - Don't do this too often or you could get temporarily suspended from obtaining new certs
      - If adding many .vip subdomains this way, finish adding them, then run `ink cert` once
