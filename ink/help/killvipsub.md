# kill vipsub

## This destroys a ...verb.vip subdomain
- This destroys a subdomain created with `new vipsub`

## Usage
- `ink kill vipsub -s [ subdomain ]`
- `ink kill vipsub -s subme`
  - Deletes the folder `vip/_subs.vip/subme`
  - Removes .conf files in `sites-available` and enables them for Apache/Nginx
  - Removes related DNS zone entries for the YOURNAME.verb.vip zone file at `conf/inkdns/inkzones/`
  - Removes the Letsencrypt domain entry from `conf/inkcert/cli-ini/`
