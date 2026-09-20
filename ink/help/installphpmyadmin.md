# install phpmyadmin

## This installs phpMyAdmin under sql.vipURI
- Lives in `www/vapps/phpmyadmin`, linked at `sql.vipURI/DIRECTORY`
- Creates a MariaDB boss user (GRANT *.*), not a database
- On failure, leftovers this install created are removed; pre-existing domain and certs stay

## Usage
- `ink install phpmyadmin -n [ directory ] [ -u dbuser ] [ -p dbpassword ]`
  - `-n` is required
  - Same as `./installphpmyadmin directory`
