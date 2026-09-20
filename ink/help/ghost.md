# ghost

## Import a Ghost site into WordPress
- Ghost's MariaDB is **read-only**. It is not rewritten into WordPress tables.
- WordPress must be installed first (`ink install wp`) into a **new** empty database.
- Then import posts, pages, tags, menus, and media with `ink ghost 2wp`.
- A Ghost nginx vhost is proxy-only (no PHP). `ghost 2wp` restores the pre-Ghost PHP vhost from `DOMAIN-ghosted.conf` so WordPress can serve.

## Schemas
Find available schemas with:
- `ink ghost -s` or
- `ink ghost --schemas`
