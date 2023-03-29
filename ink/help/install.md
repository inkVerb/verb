# install

## This installs both services and web apps
- It usually either:
  - Installs software packages from Linux repositories
    - Usually added as services, such as Postfix and Dovecot for email
    - Can install Linux packages as webapps, such as Nextcloud has an option for
    - These are done to include server-wide settings, not individual Linux packages
      - It is not recommended to install a service manually, but use this so the server handles the Linux package and its settings
  - Downloads and sets up databases with domains for web apps ('vapps'), such as:
    - WordPress
    - OrangeHRM
    - SuiteCRM
    - Ampache

## Schemas
Find available schemas with:
- `ink install -s` or
- `ink install --schemas`
