# set bimi

## This installs a BIMI SVG for a mail domain
- VIP drop: `/srv/vip/files/domain.tld.svg` (legacy `domain.tld.bimi.svg` still accepted)
- FTP drop: `/srv/ftp/domain.tld.svg`
- Destination: `/srv/www/email/bimi/domain.tld/bimi.svg`
- Public URL: `https://${emailTLDURI}/domain.tld/bimi.svg`
- The drop file is deleted after a successful install
- Adds/updates `default._bimi` TXT (`inkdnsaddbimi`)
- inkMail uploads to the VIP path, then runs this with `-p vip`
- scp/ftp: only the ink CLI installs it (SysAdmin). Verb web UI is later.

Stock Verber logo is `verb/conf/lib/cloud/bimi.svg`, placed at
`/srv/www/email/bimi/${nameURI}/bimi.svg` by `updatehtmlverbs`.

## Usage
- `ink set bimi -d [ domain.tld ] -p [ vip | ftp ]`
- `ink set bimi -p vip -d inkisaverb.com`
  - Same as `./setbimi inkisaverb.com vip`
  - inkMail uses this exact invocation
- `ink set bimi -p ftp -d inkisaverb.com`
  - For an admin who dropped `domain.tld.svg` in `/srv/ftp/`
