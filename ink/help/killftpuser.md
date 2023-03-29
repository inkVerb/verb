# kill ftpuser

## This destroys any FTP user
- This destroys any FTP user created with `new ftp`

## Usage
- `ink kill ftpuser -u [ Username ]`
- `ink ftpuser -u ftpjohn`
  - The Linux user 'ftpjohn' will be destroyed with `userdel`
  - The home folder `/srv/vsftpd/ftpjon` will be deleted
  - Other relevant folders created to manage 'ftpjohn' will also be deleted
