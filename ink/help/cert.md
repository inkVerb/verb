# cert

## This obtains and manages SSL certificates
- It will NOT work until running `ink cert install` one time
- It usually operates on the back end by:
  - Using `certbot` to obtain Letsencrypt certs
  - Keeps records in `conf/inkcert/`
  - Keeps notes in webserver .conf files
  - Uses three types of Letsencrypt certs
    - 'multiple' certs, with subdomains added to a list at `conf/inkcert/cli-ini/cli.example.tld.ini`
      - All subdomains must be created first using `ink add subdomain`, then run `ink cert do -c` for the parent domain to install certs for all subdomains
      - If subdomains are created *after* using `ink cert do -c`, then `ink cert do -c` will need to be run again
        - CAUTION: If you run `ink cert do` for a domain too often, Letsencrypt could suspend future cert requests for a cool-off period
    - 'single' certs, applied only per domain, even to subdomains created using `ink add subdomain`
      - If creating subdomains and using 'single' certs, run `ink cert do -s` for each subdomain
    - 'wildcard' certs, using a wildcard for the parent domain, then used for all subdomains created using `ink add subdomain`
      - These subdomains will use the wildcard parent cert whether created before or after obtaining the SSL cert from `ink cert do -w`
  - Removes certificates from webserver .conf files and purges them from the server with `ink cert undo`

## Schemas
Find available schemas with:
- `ink cert -s` or
- `ink cert --schemas`
