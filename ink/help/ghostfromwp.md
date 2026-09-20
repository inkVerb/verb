# ghost fromwp

## This imports WordPress posts, pages, tags, menus, and media into Ghost
- WordPress is **read-only**. Ghost must already be installed on the domain (`ink install ghost -d DOMAIN`).
- Media is copied into `content/images/` (WP originals stay). WP generated thumbs (`-150x150`) are skipped.
- Image HTML keeps wrap/align; unconstrained pictures get `max-width:100%;height:auto` so they do not overflow Ghost HTML cards.
- Authors are mapped to the existing Ghost owner (Ghost user hashes are not recreated).
- A Ghost DB dump is written to `/srv/vip/sql/wp2ghost-DOMAIN-*.sql` before import.

## Usage
- `ink ghost fromwp -d [ domain.tld ]`
  - Same as `./wp2ghost domain.tld`
- `ink ghost fromwp -d [ domain.tld ] -n`
  - Dry run
- `ink ghost fromwp -d [ domain.tld ] -m`
  - Media only
- `ink ghost fromwp -d [ domain.tld ] -v`
  - Verbose. `-d` finds both vapps on that domain.

- Standalone media helper: `./wp2ghostmedia domain.tld [ copy | move ]`
