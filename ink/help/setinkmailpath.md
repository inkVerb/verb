# set inkmailpath

## This changes the URL folder of inkMail on po.emailTLDURI
- Status: `verb/conf/servermailpath` (`ServerPOPath`)
- Live config: `/etc/inkmail/conf` (`path=`) — not the verb tree
- Nginx: `location /FOLDER/` on `po.emailTLDURI`
- Binary stays at `/srv/www/email/inkmail`

## Usage
- `ink set inkmailpath -p [ folder ]`
- `ink set inkmailpath -p wink822`
  - Same as `./setinkmailpath wink822`
