# install ghost

## This installs Ghost on a hosted domain
- Uses Node 22 LTS from `ink set serverlts` (not pacman `nodejs`)
- Lives in `/srv/ghost/DOMAIN.TLD`, proxied by Nginx (LEMP/LAEMP; not LAMP)
- Writes MariaDB credentials to `verb/conf/vapps/vapp.ghost.DOMAIN.TLD`
- Domain must already be hosted (`ink add domain`); Ghost replaces that vhost with a proxy
- Does not run inkCert; obtain certs separately with `ink cert do`
- To import an existing WordPress site on the same domain: `ink ghost fromwp -d DOMAIN` (after this install). WordPress's database is not reused.

## Usage
- `ink install ghost -d [ domain.tld ] [ -b database ] [ -u dbuser ] [ -p dbpassword ]`
  - `-d` is required
  - Database flags are optional and sequential at the serf; omit them to autogenerate

- `ink install ghost -d inkisaverb.com`
  - Same as `./installghostsite inkisaverb.com`
  - Creates `/srv/ghost/inkisaverb.com`
  - Autogenerates database, user, and password
  - Writes `verb/conf/vapps/vapp.ghost.inkisaverb.com`
  - Finish setup at `https://inkisaverb.com/ghost/`

- `ink install ghost -d inkisaverb.com -b somedb -u someuser -p somepass`
  - Same as `./installghostsite inkisaverb.com somedb someuser somepass`
