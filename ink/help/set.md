# set

## This modifies settings for vapps already installed with `ink install`
- pdt-news (`ink set pdt`)
- badAd (`ink set badad`)
- PinkWrite 99 (`ink set pw99`)
- Database credentials are rewritten in `verb/conf/vapps/vapp.APP.DOMAIN`
- App config is rewritten in the live config file
- This does not migrate data; it only changes what the app will use next

## Schemas
Find available schemas with:
- `ink set -s` or
- `ink set --schemas`
