# cert do

## This installs the inkCert SSL cert manager on the webserver
- This obtains Letsencrypt certs for domains installed on the server

## Usage
- `ink cert do -d domain.tld -c|s|w`
  - Don't run this too often or you could be temporarily suspended from obtaining certs
  - Choose a type of cert:
    - -m : "multiple" domains and subdomains in one parent domain cert
      - You can add more later with `ink add subdomain`, then run `ink cert do ...` again to update, but not too often
    - -s : "single" domain per cert
    - -w : "wildcard" cert for subdomains of the specified domain
      - Only use this for true "wildcared" purposes such as WordPress Multisite (MU), et cetera
      - If you know which subdomains you will use, and intend to not add more often if at all, use the -m flag instead of this
  - Choose which domain
    - -d domain.tld
    - -a : Apply this to all verb.* domains hosted on the server

- `ink cert do -d inkisaverb.com -m`
  - Obtains a "multiple" domain cert for inkisaverb.com and all subdomains thereof
  - `sed` replaces Apache options in `/sites-available/inkisaverb.com.conf` and all .conf files for its subdomains
