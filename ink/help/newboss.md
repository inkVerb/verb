# new boss

## This creates a new boss user that is a sudoer that can run ink commands
- This will create a new Linux user with `sudo` permissions
  - This is necessary to run `ink` commands if not running as root
- Password notes
  - Once added, the user's password must be changed because it is not secure
  - However, if the server is set to "no password login", then the password is obsolete anyway

## Usage
- `ink new boss -u [ Username ] -p [ Password ]`
  - This password will not be secure
- `ink new boss -u managerjohn -p NotSecure125`
  - The Linux sudo user will be creatd "managerjohn"
  - The user should add SSH keys to: `/home/managerjohn/.ssh/authorized_keys`
  - The user should login with: `ssh managerjohn@server.ip.address -p 5555` (if 5555 is the port)
  - The user and change the password with: `passwd`
  - The password shouldn't matter anyway since using SSH keys and "no password login" is set
