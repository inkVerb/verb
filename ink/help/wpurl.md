# wp url

## Rewrite a WordPress site URL
- Updates `wp-config.php` (`WP_HOME`, `WP_SITEURL`) and every text/blob/json column in the vapp database.
- Serialized PHP and JSON are decoded and re-encoded so media, widgets, and options stay valid.
- `-d domain.tld` finds `vapp.wp.DOMAIN` even if the public URL has not moved yet.
- Old URL must match current `WP_HOME` / `WP_SITEURL` (host or full URL). If wp-config is already at the new URL, only the database is rewritten.
- `-v` is verbose, same as every other `ink` command.

## Usage
- `ink wp url -d formosan.dog -o https://old.example -t https://formosan.dog`
  - Move the site URL to the new domain
- `ink wp url -d formosan.dog -o http://formosan.dog -t https://formosan.dog`
  - HTTP → HTTPS on the same host
- `ink wp url -d formosan.dog -o https://old.example -t https://formosan.dog -n`
  - Dry run
- Same as `/opt/verb/serfs/wpurl https://old.example https://formosan.dog -d formosan.dog`
