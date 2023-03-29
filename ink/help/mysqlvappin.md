# mysql vappin

## This creates and imports a MySQL/MariaDB database using credentials from an existing Verb web app .vapp config
- The database must be available by the name in the credentials at `vip/sql/*.sql`

## Usage
- `ink mysql vappin -a [ Verb web app name ]`
  - Creates the databased based on the vapp.* config database credentials
- `ink mysql vappin -a wp.inkisaverb.com`
  - The database will be created and imported from `vip/sql/whatever.sql` based on the database credentials at `verb/conf/vapp.wp.inkisaverb.com`
