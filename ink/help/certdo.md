# cert do

## This installs the inkCert SSL cert manager on the webserver
- This obtains Letsencrypt certs for domains installed on the server

## Usage
- `ink cert do -d domain.tld -m|s|w`
  - Don't run this too often or you could be temporarily suspended from obtaining certs
  - Choose a type of cert:
    - `-m` : "multiple" domains and subdomains in one parent domain cert
      - You can add more later with `ink add subdomain`, then run `ink cert do ...` again to update, but not too often
    - `-s` : "single" domain per cert
    - `-w` : "wildcard" domain cert
      - This requires the server to be set as "self-parking" (via `ink dns self`)
  - Choose which domain
    - `-d domain.tld`
    - `-a` : Apply this to all verb.* domains hosted on the server
- `ink cert do -d inkisaverb.com -m`
  - Obtains a "multiple" domain cert for inkisaverb.com and all subdomains thereof
  - `sed` replaces Apache/Nginx options in `/sites-available/inkisaverb.com.conf` and all `.conf` files for its subdomains
- `ink cert do -a`
  - Obtains all certificates for all `verb.` domains on the server
  - Add any `verb.one` subdomains before running this
- `ink cert do -d inkisaverb.com -s` or `ink cert do -d inkisaverb.com -w` are intended for maintenace
  - These are automatically done by `ink add domain -d inkisaverb.com -s` or `ink add domain -d inkisaverb.com -w` respectively
  - Only run this if there is a reason to refresh the certificates
  - See `ink add domain -h` to understand the corresponding use of `-s` and `-w` flags
