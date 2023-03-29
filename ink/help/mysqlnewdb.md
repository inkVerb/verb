# mysql newdb

## This creates a new MySQL/MariaDB database with a user
- The specified user is created if it does not already exist
- If the user is not specified, the database name will be attempted for the username also
- Password is optional
- If password is not set, it they will be generated automatically and displayed as output

## Usage
- `ink mysql newdb -d [ Database ] -u [ Username - defaults to Database ] -p [ Password - optional ]`
  - Creates the database and user if the user does not exist with this password
  - Grants the user permissions to use the database with this given password
- `ink mysql newdb -d somedatabase -u billybob -p bbpassword`
  - Runs the SQL query:
    - `GRANT ALL PRIVILEGES ON somedatabase.* TO 'billybob'@'localhost' IDENTIFIED BY 'bbpassword;`
    - Success output:
    Database 'somedatabase' created for user 'billybob'.
- `ink mysql newdb -d somedatabase -u billybob`
  - Runs the SQL query:
    - `GRANT ALL PRIVILEGES ON somedatabase.* TO 'billybob'@'localhost' IDENTIFIED BY 'Awrandy386;`
    - Success output:
    Database 'somedatabase' created for user 'billybob'.
    New Password: Awrandy386
- `ink mysql newdb -d somedatabase`
  - Runs the SQL query:
    - `GRANT ALL PRIVILEGES ON somedatabase.* TO 'somedatabase'@'localhost' IDENTIFIED BY 'Awrandy386;`
    - Success output:
    Database 'somedatabase' created for user 'somedatabase'.
    New Password: Awrandy386
