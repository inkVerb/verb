# wp

## WordPress post/page type tools
- Convert posts to pages: `ink wp pagify`
- Convert pages to posts: `ink wp postify`
- Fit overflowing images: `ink wp fitimages` (after Ghost → WP import)
- Rewrite the site URL (wp-config + whole database): `ink wp url`
- Ghost → WordPress import creates **posts**. Use pagify if you wanted pages.
- `-d domain.tld` finds `vapp.wp.DOMAIN` (no separate vapp flag)
- `-v` is verbose, same as every other `ink` command
- Exactly one of `-p ID`, `-g` (list Title/slug/ID), or `-a` (all) for pagify/postify

## Schemas
Find available schemas with:
- `ink wp -s` or
- `ink wp --schemas`
