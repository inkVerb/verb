# add domainfiler

## This adds a hosted domain to an FTP filer
- The FTP filer (FTP user) will then be able to access the domain found in `www/domains` via link
  - A symlink will be created in the filer's directory at `filer/_domains/newdomain.tld`


## Usage
- `ink add domainfiler -d [ somedomain.tld ] -f [ ftpfiler_username ]`

- `ink add domainfiler -d inkisaverb.com -f johnsmith`
  - Creates a symlink from `www/domains/inkisaverb.com` to `filers/johnsmith/_domains/inkisaverb.com`

