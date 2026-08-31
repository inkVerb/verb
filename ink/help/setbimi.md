# set bimi

## This installs a BIMI SVG for a hosted domain
- VIP drop: `/srv/vip/files/domain.tld.bimi.svg`
- FTP drop: `/srv/ftp/domain.tld.bimi.svg`
- Destination always: `/srv/www/html/domain.tld/bimi.svg` (must already be the site link; no mkdir)
- Verb URIs from siteurilist are refused (exit 5)
- Adds `default._bimi` TXT (`inkdnsaddbimi`, DNS only)
- inkMail uploads to the VIP path, then runs this with `-p vip`

## Usage
- `ink set bimi -d [ domain.tld ] -p [ vip | ftp ]`
- `ink set bimi -p vip -d inkisaverb.com`
  - Same as `./setbimi inkisaverb.com vip`
  - inkMail uses this exact invocation
- `ink set bimi -p ftp -d inkisaverb.com`
  - For an FTP-operating admin who dropped `domain.tld.bimi.svg` in `/srv/ftp/`
