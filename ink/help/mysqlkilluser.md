# mysql killuser

## This drops a MySQL/MariaDB database
- This runs a `DROP USER` query

## Usage
- `ink mysql killdb -u [ Database User ]`
- `ink mysql killdb -u somedbuser`
  - Runs the SQL query:
    - `DROP USER somedbuser;`
