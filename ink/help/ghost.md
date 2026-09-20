# ghost

## Ghost sites on a Verber
- Install with `/opt/verb/serfs/installghostsite [ domain.tld ]` (uses Node 22 LTS from `ink set serverlts`, not pacman `nodejs`).
- **Import Ghost → WordPress:** `ink ghost 2wp` — Ghost DB is read-only; install WordPress first.
- **Import WordPress → Ghost:** `ink ghost fromwp` — WordPress is read-only; install Ghost first.
- A Ghost nginx vhost is proxy-only (no PHP). `ghost 2wp` restores the pre-Ghost PHP vhost from `DOMAIN-ghosted.conf` so WordPress can serve.

## Schemas
Find available schemas with:
- `ink ghost -s` or
- `ink ghost --schemas`
