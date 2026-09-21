# wp url

## Rewrite a WordPress site URL
- Updates `wp-config.php` (`WP_HOME`, `WP_SITEURL`) and every text/blob/json column in the vapp database.
- Serialized PHP and JSON are decoded and re-encoded so media, widgets, and options stay valid.
- `-d` is the **hosted domain only** (no `https://`). That finds `vapp.wp.DOMAIN` even if the public URL has not moved yet.
- `-o` and `-t` are full URLs: `https://host` is valid (path not required).
- Old URL must match current `WP_HOME` / `WP_SITEURL` (host or full URL). If wp-config is already at the new URL, only the database is rewritten.
- `-v` is verbose, same as every other `ink` command.

## Usage
- `ink wp url -d church.jesse.house -o https://jesse.church -t https://church.jesse.house`
  - Move the site URL onto the hosted domain
- `ink wp url -d church.jesse.house -o https://church.jesse.house -t https://jesse.church`
  - The other direction
- `ink wp url -d formosan.dog -o http://formosan.dog -t https://formosan.dog`
  - HTTP → HTTPS on the same host
- `ink wp url -d church.jesse.house -o https://jesse.church -t https://church.jesse.house -n`
  - Dry run
- Same as `/opt/verb/serfs/wpurl https://jesse.church https://church.jesse.house -d church.jesse.house`
