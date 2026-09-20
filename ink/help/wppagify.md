# wp pagify

## Convert WordPress posts to pages
- MariaDB `post_type` post → page. Ghost, attachments, revisions, and auto-drafts are skipped.
- `-d` extra-checks the hosted domain and `vapp.wp.DOMAIN`. `-v` is the vapp `wp.domain.tld`.
- Exactly one of `-d` or `-v`. Exactly one of `-p`, `-g`, or `-a`.
- `-g` prints a tab-separated table: Title, slug, ID (posts only). Use those IDs with `-p`.
- Menu items that pointed at converted posts are updated to object `page`.

## Usage
- `ink wp pagify -d formosan.dog -g`
  - List posts (Title, slug, ID)
- `ink wp pagify -d formosan.dog -a`
  - Convert every post to a page
- `ink wp pagify -d formosan.dog -p 42`
  - Convert post ID 42 to a page
- `ink wp pagify -v wp.formosan.dog -a`
  - Same, via the vapp name
- Same as `/opt/verb/serfs/wppagify domain formosan.dog all`
