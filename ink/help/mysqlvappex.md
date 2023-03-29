# mysql vappex

## This exports a MySQL/MariaDB database using credentials from an existing Verb web app .vapp config
- The database will be available by the name in the credentials at `vip/sql/*.sql`

## Usage
- `ink mysql vappex -a [ Verb web app name ]`
  - Creates the databased based on the vapp.* config database credentials
- `ink mysql vappex -a wp.inkisaverb.com`
  - The database will be exported to `vip/sql/whatever.sql` based on the database credentials at `verb/conf/vapp.wp.inkisaverb.com`
