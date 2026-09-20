# wp postify

## Convert WordPress pages to posts
- Inverse of `ink wp pagify`. MariaDB `post_type` page → post.
- `-d` extra-checks the hosted domain and `vapp.wp.DOMAIN`. `-v` is the vapp `wp.domain.tld`.
- Exactly one of `-d` or `-v`. Exactly one of `-p`, `-g`, or `-a`.
- `-g` prints a tab-separated table: Title, slug, ID (pages only). Use those IDs with `-p`.
- Menu items that pointed at converted pages are updated to object `post`.

## Usage
- `ink wp postify -d formosan.dog -g`
  - List pages (Title, slug, ID)
- `ink wp postify -d formosan.dog -a`
  - Convert every page to a post
- `ink wp postify -d formosan.dog -p 42`
  - Convert page ID 42 to a post
- `ink wp postify -v wp.formosan.dog -a`
  - Same, via the vapp name
- Same as `/opt/verb/serfs/wppostify domain formosan.dog all`
