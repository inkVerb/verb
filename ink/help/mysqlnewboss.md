# mysql newboss

## This adds a new admin database usere
- Password is optional
- If password are not set, then it will be generated automatically and displayed as output

## Usage
- `ink mysql newboss -u [ Username ] -p [ Password - optional ]`
  - Creates the user if it does not exist, with this password
  - Grants the user permissions on all tables, with `GRANT` option
- `ink mysql newboss -u billybob -p bbpassword`
  - Runs the SQL query:
    - `GRANT ALL PRIVILEGES ON *.* TO 'billybob'@'localhost' IDENTIFIED BY 'bbpassword;`
    - Success output:
    User created 'billybob'.
- `ink mysql newboss -d billybob`
  - Runs the SQL query:
    - `GRANT ALL PRIVILEGES ON *.* TO 'randoM1812'@'localhost' IDENTIFIED BY 'Awrandy386;`
    - Success output:
    User created 'billybob'.
    New Password: Awrandy386
