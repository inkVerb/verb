# install ldap

## This installs OpenLDAP on this Verber
- Marker: `verb/conf/ldap/ldapinstalled`
- Does not undo PAM edits on failure (system-auth). Package is removed only if this install added it.
- On failure, slapd is stopped if this install started it; pre-existing OpenLDAP stays

## Usage
- `ink install ldap`
  - Same as `./installldap`
