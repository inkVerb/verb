#!/bin/bash

# Set the serf name
SURFNAME="newdomainshell"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This creates a new framework for managing a domain's OpenDKIM keys, SSL certs, mail domain, and DNS zone.
This does not crate any Apache/Nginx configs nor web folders.
This is usually handled by:
  # ink add domain
  # ink add subdomain
Use this if you only need a mail domain or need to make changes to thee DNS zone before going live with a site.
To make the domain site live with Apache/Nginx and web folders, use:
  # ink add domain
Or, make a subdomain live with:
  # ink add subdomain
Using either of these two above will run this "ink new domainshell" process automatically.
EOU
)"

# Available flags
optSerf="d:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="A new domain to create a framework for"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
  ;;
  # Standard flags
  c)
    SOcli="true"
  ;;
  v)
    SOverbose="true"
  ;;
  h)
    SOh="true"
  ;;
  r)
    richtext="true"
  ;;
  *)
    inkFail
  ;;
 esac
done

# Message prep
# Success message
success_message="$SOd domain framework added."

# Fail message
fail_message="$SOd domain framework failed to be added."

# Check requirements or defaults
## Help
if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}"
  /bin/echo "
Available flags:
-h This help message
-d ${optName[d]}: ${optDesc[d]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOd}"

# Run the ink
. $InkRun
