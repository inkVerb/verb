# install vmail

## This installs and sets up a Postfix-RoundCube-PostfixAdmin email server
- This will install Linux packages for `postfix`, `dovecot`, and related packages
- This downloads and sets up databases with verb subdomains for RoundCube and PostfixAdmin
  - These will reside in `www/email/` and will have symlink directories in `www/verb/`

## Usage
- `ink install vmail -r [ RoundCube web folder ] -p [ PostfixAdmin web folder ] -s [ PostfixAdmin setup password ] -b [ Vmail backup file ]`
  - All flags are optional!

- `ink install vmail -r someDir1 -p someOtherDir2 -s set4MeUP -b verb.vmail.rAnD8mn5l3.vbak`
  - Creates the email folders `www/email/roundcube` & `www/email/postfixadmin` makes them live in `www/verb/email.box` & `www/verb/email.po`
  - Installs packages for:
    - `postfix`
    - `dovecot`
    - Some possible dependencies
  - Downloads web apps from roundcube.net and PostfixAdmin's SourForge page
  - Creates databases with apps at:
    - verb/conf/vapps/vapp.roundcube
    - verb/conf/vapps/vapp.postfixadmin
