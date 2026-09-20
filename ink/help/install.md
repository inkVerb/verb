# install

## This installs both services and web apps
- It usually either:
  - Installs software packages from Linux repositories
    - Usually added as services, such as Postfix and Dovecot for email
    - Can install Linux packages as webapps, such as Nextcloud has an option for
    - These are done to include server-wide settings, not individual Linux packages
      - It is not recommended to install a service manually, but use this so the server handles the Linux package and its settings
  - Downloads and sets up databases with domains for web apps ('vapps'), such as:
    - WordPress (`ink install wp`)
    - Ghost (`ink install ghost`) — Node 22 LTS via `ink set serverlts`
    - Ghost → WordPress import (`ink ghost 2wp`) after WordPress is installed
    - pdt-news (`ink install pdt`)
    - badAd (`ink install badad`)
    - PinkWrite 99 (`ink install pw99`)
    - Nextcloud (`ink install nextcloud`)
    - ownCloud OCIS (`ink install owncloud`)
    - Pydio (`ink install pydio`)
    - OrangeHRM (`ink install orangehrm`)
    - SuiteCRM (`ink install suitecrm`)
    - MediaWiki (`ink install mediawiki`)
    - phpMyAdmin (`ink install phpmyadmin`)
    - LDAP (`ink install ldap`)
    - inkMail (`ink install inkmailadmin`) — agnostic mail panel at po.emailTLDURI
    - Verb web UI (`ink install verbadmin`) — vipURI, only if VERBvip=true before setup
    - Ampache
- If an `ink install` vapp serf fails, it undoes what that run created (new DB, vapp tree, vapp conf, html symlink it made). A domain and inkCert that already existed stay. A leftover incomplete install is cleaned on retry instead of “already installed.”

## Schemas
Find available schemas with:
- `ink install -s` or
- `ink install --schemas`
