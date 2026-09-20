# wp postify

## Convert WordPress pages to posts
- Inverse of `ink wp pagify`. MariaDB `post_type` page → post.
- `-d domain.tld` finds `vapp.wp.DOMAIN`. `-v` is verbose (not a vapp).
- Exactly one of `-p`, `-g`, or `-a`.
- `-g` prints a tab-separated table: Title, slug, ID (pages only). Use those IDs with `-p`.
- Menu items that pointed at converted pages are updated to object `post`.

## Usage
- `ink wp postify -d formosan.dog -g`
  - List pages (Title, slug, ID)
- `ink wp postify -d formosan.dog -a`
  - Convert every page to a post
- `ink wp postify -d formosan.dog -p 42`
  - Convert page ID 42 to a post
- `ink wp postify -d formosan.dog -a -v`
  - Same, with serf stdout
- Same as `/opt/verb/serfs/wppostify domain formosan.dog all`
