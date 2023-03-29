# kill

## This removes domain framework items from the server
- These were usually created with
  - `ink new`
  - `ink add`
  - `ink cert`
  - `ink install`
  - `ink mysql`
- Including
  - domains
  - Letsencrypt entries
  - DNS entries
  - OpenDKIM entries
  - Mail domains and folders
  - Web apps
  - Users
    - FTP
    - SQL
    - "Boss" sudoers

## Schemas
Find available schemas with:
- `ink kill -s` or
- `ink kill --schemas`
