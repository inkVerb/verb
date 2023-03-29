# kill dkim

## This creates new domain DKIM keys for a hosted domain
- This will destroy OpenDKIM keys
- This *will not* remove any entries from a DNS zone file

## Usage
- `ink kill dkim -d [ somedomain.tld ]`
- `ink kill dkim -d inkisaverb.com`
  - Deletes keys in `/etc/opendkim/keys/inkisaverb.com/`
  - Removes records and entries:
    - `/etc/opendkim/KeyTable`
    - `/etc/opendkim/SigningTable`
