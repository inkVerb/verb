# mysql boss

## This logs into the MySQL/MariaDB console
- A specific boss user may be used, if the user was created using `ink mysql newboss`
- If not specified, then the default SQL admin user will be used
- This allows simple entry to the MySQL/MariaDB prompt because the username and password are stored securely and will not be entered in the command line

## Usage
- `ink mysql boss -u [ Username - optional ]`
  - Creates the user if it does not exist, with this password
  - Grants the user permissions to use the database with this given password
- `ink mysql boss`
  - Enter the MySQL/MariaDB terminal using the default SQL admin
- `ink mysql boss -u billybob`
  - Enter the MySQL/MariaDB terminal using the billybob SQL admin
    - If admin user billybob does not exist, the command will fail
