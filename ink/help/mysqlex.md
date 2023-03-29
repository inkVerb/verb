# mysql ex

## This exports a MySQL/MariaDB database
- The database will become available by the same name at `vip/sql/*.sql`
  - This can be accessed by FTP users created with `new ftp filer` or `new ftp vip`
  - An FTP 'filer' will see 'sql/'; an FTP VIP will see 'vip/sql/'

## Usage
- `ink mysql ex -d [ Database ]`
  - Exports the database to the `vip/sql` directory
- `ink mysql ex -d somedatabase`
  - 'somedatabase.sql' will be available at `sql/somedatabase.sql` for FTP users
