# This explains the workflow if inkDNS Bind hosting on inkVerb Verbers and Inkers

## Domains and subdomains may be added and otherwised managed whether inkDNS has been installed or not.

- inkDNS needs to be installed before use, but has pre-install framework as part of the core Verber operations, which it uses to create entries in the inkDNS Bind framework
- inkDNS never makes direct modifications to its Bind framework; it only "refreshes" (deletes, then re-creates) record & registry files in the Bind framework based on the Bind DNS framework maintained by Verber

## General Flow
- inkDNS must be installed first:
1. On any Verber that will use manage its own DNS records
2. On the Inker that Verbers will use for secondary DNS hosting

How to install:
- On Verber use `inkdnsinstall` (serf)
- On Inker use `inkdnsinkinstall` (knight)

## Verber

### Install:
- `inkdnsinstall`

### Settings (choosing the Inker(s), does not require inkDNS to be installed)
- `inkdnssetns1` & `inkdnssetns2`

### Nothing else
- There are no other inkDNS settings on a Verber becuase all inkDNS Bind DNS zone settings are inherited from the Verber's framework.
- Once installed, inkDNS on the Verber will automatically "refresh" itself when any changes are made to domains.

## Inker

### Install
- `inkdnsinkinstall`

### Manage Verbers
*numbered by system dependency hierarchy, not redundantly run each time)*

#### Basic Verber
1. `verberadd` (one time per verber)
2. `verberdomain` (one time per domain)
3. `verberdomainkill`
4. CURRENTLY NO VERBER KILLER

#### Multi-Verber
1. Basic Verber already installed (the Verber must have already been added to this Inker)
2. `verberstatus` ('multi' option)
3. `verbermulti` (new verber, same NAME, new 'tld')
4. `verbermovetld` (tertiary tld EXISTS WHEREVER to new destination Verber's by 'tld' option)

#### Refresh system
*This must run after making any changes to a Verber*
1. `inkdnsinkrefreshverber` (verber name)

*This must run after adding or removing a Verber*
2. `inkdnsinkrefreshrink` (no parameters)

