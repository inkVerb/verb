#!/bin/bash

# Set the serf name
SURFNAME="adddomain"

# Include the settings & functions
. ${INKSET}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This adds a new domain, complete with OpenDKIM profiles and keys and inkCert and Apache configs
This also creates a folder for the domain in www/domains which an ftpvip can access
This also creates an inkDNS zone file, complete with mail records
EOU
)"

# Available flags
optSerf="d:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="A new domain (or subdomain if using for email and unique SSL certificates)"

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
success_message="$SOd domain added."

# Fail message
fail_message="$SOd domain failed to be added."

# Check requirements or defaults
## HELP
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
