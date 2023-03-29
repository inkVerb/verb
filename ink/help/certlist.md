# cert list

## This lists the subdomains included in a "multiple" Letsencrypt SSL cert managed by inkCert on the webserver
- This the 'domains =' line in the Letsencrypt cli.ini file
- These are the subdomains that will apply if running `ink cert do -c` with the `-c` flag
  - They will consequentially be affected if running `ink cert undo` for the domain

## Usage
- `ink cert list -d domain.tld`

- `ink cert do -d inkisaverb.com`
  - Lists 'inkisaverb.com' and all subdomains added with `ink add subdomain`
  - Running `ink cert do -d inkisaverb.com -c` Will obtain one cert named 'inkisaverb.com', installed for all these subdomains
