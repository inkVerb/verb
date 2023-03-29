# mysql addusr

## This adds a new or existing user to an existing database
- Username and password are optional
- If username and/or password are not set, then they will be generated automatically and displayed as output
- If the username was already created using the `ink mysql` action, then that same username and password will be applied, regardless of whether the -p Password flag is used
- You cannot set a password without a user; the command will fail if you try to

## Usage
- `ink mysql addusr -d [ Database ] -u [ Username - optional ] -p [ Password - optional ]`
  - Creates the user if it does not exist, with this password
  - Grants the user permissions to use the database with this given password
- `ink mysql addusr -d somedatabase -u billybob -p bbpassword`
  - Runs the SQL query:
    - `GRANT ALL PRIVILEGES ON somedatabase.* TO 'billybob'@'localhost' IDENTIFIED BY 'bbpassword;`
    - Success output:
    User added to database 'somedatabase'.
- `ink mysql addusr -d somedatabase -u billybob`
  - Runs the SQL query:
    - `GRANT ALL PRIVILEGES ON somedatabase.* TO 'billybob'@'localhost' IDENTIFIED BY 'Awrandy386;`
    - Success output:
    User added to database 'somedatabase'.
    New Password: Awrandy386
- `ink mysql addusr -d somedatabase`
  - Runs the SQL query:
    - `GRANT ALL PRIVILEGES ON somedatabase.* TO 'randoM1812'@'localhost' IDENTIFIED BY 'Awrandy386;`
    - Success output:
    User added to database 'somedatabase'.
    New User: randoM1812
    New Password: Awrandy386
