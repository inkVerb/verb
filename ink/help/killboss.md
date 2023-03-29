# kill boss

## This destroys a boss user that is a sudoer that can run ink commands
- This will delete a new Linux user with `sudo` permissions, created with `ink new boss`
- This will delete the Linux user's home folder in `/home/`

## Usage
- `ink kill boss -u [ Username ]`
- `ink kill boss -u managerjohn`
  - The Linux sudo user will be deleted "managerjohn"
  - The home folder will be removed: `/home/managerjohn/`
