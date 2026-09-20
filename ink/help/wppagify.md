# wp pagify

## Convert WordPress posts to pages
- MariaDB `post_type` post → page. Ghost, attachments, revisions, and auto-drafts are skipped.
- `-d domain.tld` finds `vapp.wp.DOMAIN`. `-v` is verbose (not a vapp).
- Exactly one of `-p`, `-g`, or `-a`.
- `-g` prints a tab-separated table: Title, slug, ID (posts only). Use those IDs with `-p`.
- Menu items that pointed at converted posts are updated to object `page`.

## Usage
- `ink wp pagify -d formosan.dog -g`
  - List posts (Title, slug, ID)
- `ink wp pagify -d formosan.dog -a`
  - Convert every post to a page
- `ink wp pagify -d formosan.dog -p 42`
  - Convert post ID 42 to a page
- `ink wp pagify -d formosan.dog -a -v`
  - Same, with serf stdout
- Same as `/opt/verb/serfs/wppagify domain formosan.dog all`
