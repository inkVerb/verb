# cert undo

## This removes specific inkCert SSL certs domain on the webserver
- These were certs obtained with `ink cert do`
- A domain must be specified because the certs are named by a domain
  - But, more domains could be affected

## Usage
- `ink cert undo -d domain.tld`

- `ink cert undo -d inkisaverb.com`
  - Removes and purges all certs for inkisaverb.com in `/etc/inkcert/le/...`
  - `sed` replaces Apache options in `/sites-available/inkisaverb.com.conf`
  - And will either:
    - Apply to subdomains thereof and all .conf files for its subdomains
    - Not apply to subdomains if the certs were installed using the -s flag wtih `ink cert do -s`
