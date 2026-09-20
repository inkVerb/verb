# ghost fromwp

## This imports WordPress posts, pages, tags, menus, and media into Ghost
- WordPress is **read-only**. Ghost must already be installed on the domain (`ink install ghost -d DOMAIN`).
- Media is copied into `content/images/` (WP originals stay). WP generated thumbs (`-150x150`) are skipped.
- Authors are mapped to the existing Ghost owner (Ghost user hashes are not recreated).
- A Ghost DB dump is written to `/srv/vip/sql/wp2ghost-DOMAIN-*.sql` before import.

## Usage
- `ink ghost fromwp -d [ domain.tld ]`
  - Same as `./wp2ghost domain.tld`
- `ink ghost fromwp -d [ domain.tld ] -n`
  - Dry run
- `ink ghost fromwp -d [ domain.tld ] -m`
  - Media only

- Standalone media helper: `./wp2ghostmedia domain.tld [ copy | move ]`
