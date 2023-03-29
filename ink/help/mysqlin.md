# mysql in

## This imports a MySQL/MariaDB database
- The database must be available by the same name at `vip/sql/*.sql`
  - This can be accessed by FTP users created with `new ftp filer` or `new ftp vip`
  - An FTP 'filer' will see 'sql/'; an FTP VIP will see 'vip/sql/'

## Usage
- `ink mysql in -d [ Database ]`
  - Imports the database from the `vip/sql` directory
- `ink mysql in -d somedatabase`
  - Database `sql/somedatabase.sql` will be imported to 'somedatabase'
