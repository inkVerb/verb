# inkMail

Postfix-Maddy agnostic mail control plane for a Verber.

- Talks to `ink mail …` which picks `inkemail*` or `inkvmail*`
- BIMI: write `/srv/vip/files/domain.tld.svg` then `ink set bimi -p vip -d domain.tld` (served at `https://${emailTLDURI}/domain.tld/bimi.svg`)
- Lives at po.emailTLDURI after `ink install inkmailadmin`
- Same PFA-shaped UI as [MaddyAdmin](https://github.com/inkVerb/MaddyAdmin), but no Maddy CLI
- Pluggable: set `domain_lock=example.com` in `/etc/inkmail/conf` (pdt enterprise module — one inbox/alias per subdomain of that domain)
- Single operator identity in `/etc/inkmail/admin.json` (not MariaDB)

## Login methods
Password, passkey, Google, GitHub, TOTP Authenticator, and SSO from the verb (or rink) web UI (`sso_secret`). First visit with no password hash is a set-password form.

Password login can be turned off only after a passkey **and** a linked Google or GitHub login are on. Keep at least one way in. Authenticator still applies after passkey or social login.

Locker (name, email, theme) → Password → Security is the hub. Themes apply when signed in. Empty domain/box lists say **Nothing yet**.

## Google and GitHub
Empty `id` or `secret` in `/etc/inkmail/conf` hides that button. Callback is `{origin}{path}oauth` (the `path=` value from conf, with a trailing slash).

| Provider | Where to get the keys | Conf keys |
|---|---|---|
| Google | [Google Cloud credentials](https://console.cloud.google.com/apis/credentials) — **OAuth client ID**, application type **Web application**. Authorized redirect URI: `https://po.{emailTLDURI}/{path}/oauth` | `oauth_google_id`, `oauth_google_secret` |
| GitHub | [GitHub Developer settings](https://github.com/settings/developers) — **OAuth Apps** → New OAuth App. Authorization callback URL: same as Google | `oauth_github_id`, `oauth_github_secret` |

OAuth does not create a second operator. Sign in (password, passkey, or SSO), then Connect from Security.

## Config `/etc/inkmail/conf`
```
listen=127.0.0.1:8099
path=/abc12/
sso_secret=…
sess_secret=…
domain_lock=
vip_drop=/srv/vip/files
oauth_google_id=
oauth_google_secret=
oauth_github_id=
oauth_github_secret=
admin_json=/etc/inkmail/admin.json
```
