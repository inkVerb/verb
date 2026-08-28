# new verbadmin

## This creates a nologin PAM user for the verb web UI
- Groups: `verb` plus exactly one of `admin` or `supervisor`
- No home, no shell, no sudo — authentication only
- SQL meta at `conf/webadmin/users.db` is a redundant cross-check of account type
- Login fails closed if PAM groups and SQL type disagree
- One-time password; first login must change it, confirm email, and enroll Authenticator or Passkey
- The verb web UI cannot create other admins. Only `ink` / this serf or the rink.

## Usage
- `ink new verbadmin -u [ username ] -t [ admin | supervisor ] -e [ email ]`
- `ink new verbadmin -u jesse -t admin -e jesse@inkisaverb.com`
