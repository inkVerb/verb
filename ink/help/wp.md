# wp

## WordPress post/page type tools
- Convert posts to pages: `ink wp pagify`
- Convert pages to posts: `ink wp postify`
- Ghost → WordPress import creates **posts**. Use pagify if you wanted pages.
- `-d domain.tld` extra-checks the hosted domain and `vapp.wp.DOMAIN`
- `-v wp.domain.tld` is the vapp name (not ink verbose)
- Exactly one of `-p ID`, `-g` (list Title/slug/ID), or `-a` (all)

## Schemas
Find available schemas with:
- `ink wp -s` or
- `ink wp --schemas`
