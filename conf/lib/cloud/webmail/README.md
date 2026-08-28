# inkMail

Postfix-Maddy agnostic mail control plane for a Verber.

- Talks to `ink mail …` which picks `inkemail*` or `inkvmail*`
- BIMI: write `/srv/vip/files/domain.tld.bimi.svg` then `ink set bimi -p vip -d domain.tld`
- Lives at po.emailURI after `ink install inkmailadmin`
- Same PFA-shaped UI as [MaddyAdmin](https://github.com/inkVerb/MaddyAdmin), but no Maddy CLI
- Pluggable: set `domain_lock=example.com` in `inkmail.conf` (pdt enterprise module — one inbox/alias per subdomain of that domain)
- SSO from the verb (or rink) web UI via HMAC cookie (`sso_secret`)
