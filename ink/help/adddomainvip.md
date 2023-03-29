# add domainvip

## This adds a hosted domain to the primary VIP directory accessible through FTP
- The FTP filer (FTP user) will then be able to access the domain found in `www/domains` via link
  - A symlink will be created in the filer's directory at `vip/_domains/newdomain.tld`


## Usage
- `ink add domainvip -d [ somedomain.tld ]`

- `ink add domainvip -d inkisaverb.com`
  - Creates a symlink from `www/domains/inkisaverb.com` to `vip/_domains/inkisaverb.com`

