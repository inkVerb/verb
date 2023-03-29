# activate domain

## This activates a hosted domain to either work with either:
- An FTP-accessible directory in `www/domains/`
- Or a "Vapp" (Verber-installed app) in `www/vapps/`
  - Vapp names must match the directory used
  - WordPress Vapps use the domain prefix `wp` such as `wp.inkisaverb.com`
  - Other common Vapp names: `nextcloud`, `phpmyadmin`, `suitecrm` using standard all-lowercase in one word
- Activated domains originate from `www/html/`

## Usage
- `ink activate domain -d [ somedomain.tld ] -v [ vappname (optional) ]`

- `ink activate domain -d inkisaverb.com`
  - Links hosted `www/html/inkisaverb.com` to FTP location `www/domains/inkisaverb.com`

- `ink activate domain -d inkisaverb.com -v wp.inkisaverb.com`
  - Links hosted `www/html/inkisaverb.com` to Vapp location `www/vapps/wp.inkisaverb.com`

- `ink activate domain -d cloud.inkisaverb.com -v nextcloud`
  - Links hosted `www/html/cloud.inkisaverb.com` to Vapp location `www/vapps/nextcloud`
