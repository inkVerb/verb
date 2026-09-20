# wp fitimages

## Fit WordPress post/page images to the content width
- One-time (and idempotent) cleanup after `ink ghost 2wp`. Ghost stored `width="2488"` on `<img>`; WordPress themes do not include Ghost’s `kg-image { max-width:100% }` CSS, so pictures overflow the post body.
- Sets `max-width:100%;height:auto;width:auto` unless the image already has a percent width, float, or align wrap.
- Maps Ghost `kg-width-wide` / `kg-width-full` to WP `alignwide` / `alignfull`. Keeps `alignleft` / `alignright` / `aligncenter`.
- Uses `verb/conf/vapps/vapp.wp.DOMAIN` (MariaDB via that vapp’s `wp-config.php`). Ghost is not touched.

## Usage
- `ink wp fitimages -d formosan.dog`
  - Same as `/opt/verb/serfs/wpfitimages formosan.dog`
- `ink wp fitimages -d formosan.dog -n`
  - Dry run
- `ink wp fitimages -d formosan.dog -v`
  - Verbose (lists each post updated)
