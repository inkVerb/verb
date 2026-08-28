# install vmail

## This installs and sets up a Postfix-RoundCube email server plus one po.emailURI admin
- Linux packages for `postfix`, `dovecot`, and related packages
- Roundcube on `box.emailURI`
- Mail admin on `po.emailURI`: PostfixAdmin by default (`pfa`), or inkMail (`ima`)
- PFA and inkMail can both exist later as primaries, but they must use different po. paths (exit 7 on collision)
- These will reside in `www/email/` and will have symlink directories in `www/verb/`

## Usage
- `ink install vmail -r [ RoundCube web folder ] -p [ po. web folder ] -a [ pfa | ima ] -s [ PostfixAdmin setup password ] -b [ Vmail backup file ]`
  - All flags are optional. `-a` defaults to `pfa`. `-s` is ignored when `-a ima`.

- `ink install vmail -r someDir1 -p someOtherDir2 -s set4MeUP -b verb.vmail.rAnD8mn5l3.vbak`
  - PostfixAdmin at `https://po.emailURI/someOtherDir2`
  - Roundcube at `https://box.emailURI/someDir1`

- `ink install vmail -r someDir1 -p imaDir -a ima`
  - inkMail at `https://po.emailURI/imaDir` instead of PFA
  - Same Postfix/Dovecot stack

- Creates databases with apps at:
  - verb/conf/vapps/vapp.roundcube
  - verb/conf/vapps/vapp.postfixadmin (pfa only)
