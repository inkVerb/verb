# new dkim

## This creates new domain DKIM keys for a hosted domain
- This will create OpenDKIM keys, suited for the inkVerb framework
  - They are ready for inclusion with DNS records
  - They will be sent with email headers using the ink-installed Postfixemail server
- This *will not* add any entries from a DNS zone file
- This is automatically handled by `ink add domain` and `ink new domainshell`, but may be useful if the web admin needs to refresh OpenDKIM keys manually
  - To refresh OpenDKIM keys manually, first use `ink kill dkim`

## Usage
- `ink new dkim -d [ somedomain.tld ]`
- `ink new dkim -d inkisaverb.com`
  - Creates keys in `/etc/opendkim/keys/inkisaverb.com/`
  - Adds records and entries:
    - `/etc/opendkim/KeyTable`
    - `/etc/opendkim/SigningTable`
