# new ftp

## This creates an FTP user
- This will create a new FTP user through the `vsftpd` Linux package
- There are different types of FTP users:
  - 'user'
    - Access to a specific FTP folder in `vsftpd/ftp_user/`
      - A subfolder `files.vip/` linked to the `www/vip/files/` directory, which is reached at files.YOURNAME.verb.vip/ftp_user/
  - `filer`
    - Access to a specific FTP folder in `vsftpd/ftp_user/`
      - A subfolder `files.vip/` linked to the `www/vip/files/` directory, which is reached at files.YOURNAME.verb.vip/ftp_user/
    - Links in home folder to `vip/_filecabinet` and `vip/sql`
    - A `_domains` folder that can be connected to specific domains
  - 'vip'
    - Access to a specific FTP folder in `vsftpd/ftp_user/`
      - A subfolder `files.vip/` linked to the `www/vip/files/` directory, which is reached at files.YOURNAME.verb.vip/ftp_user/
    - Link in home folder to `vip/` folder, which can access many other things

## Usage
- `ink ftp -t [ Type ] -u [ Username ] -p [ Password ]`
- `ink ftp -t user -u ftpjohn -p SomePassword86`
  - The FTP user home folder will be created at `/srv/vsftpd/ftpjohn`
  - This home folder will contain:
    - `files.vip` linked to files.YOURNAME.verb.vip/ftpjohn/
- `ink ftp -t filer -u ftpjohn -p SomePassword86`
  - The FTP user home folder will be created at `/srv/vsftpd/ftpjohn`
  - This home folder will contain:
    - `files.vip/` linked to files.YOURNAME.verb.vip/ftpjohn/
    - `_filecabinet/` shared folder with other filers
    - `sql/` to access imported and exported SQL databases
    - `_domains` to access domains granted access to via `ink add domainfiler`
- `ink ftp -t vip -u ftpjohn -p SomePassword86`
  - The FTP user home folder will be created at `/srv/vsftpd/ftpjohn`
  - This home folder will contain:
    - `files.vip/` linked to files.YOURNAME.verb.vip/ftpjohn/
    - `vip/` link, which contains:
      - `_domains/`
      - `_filecabinet/`
      - `files/`
      - `ftpusers/`
      - `repo/`
      - `req/ -> /etc/inkcert/req/` (not used for much, may be depreciated)
      - `sql/`
      - `_subs.vip/` (for SUB.verb.YOURNAME.vip subdomains added with `ink new vipsub`)
      - `_webapps` (for custom web apps, accessible somewhere by the server admin)
