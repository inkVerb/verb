#!/bin/bash

# Set the serf name
surfname="adddomain"

# Include the settings & functions
. ${InkSet}
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
optName[a]="Automatic inkCert"
optDesc[a]="Choose 'multi' or 'wild'"
optName[d]="Domain"
optDesc[d]="A new domain (or subdomain if using for email and unique SSL certificates)"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  a)
    isDomain "${OPTARG}" "${optName[a]}"
    SOa="${OPTARG}"
  ;;
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

# Message prep
# Success message
success_message="$SOd domain added."

# Fail message
fail_message="$SOd domain failed to be added."

## Required flags & defaults
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi
## Required flags & defaults
if [ -z "${SOa}" ]; then
  SOa="" # Uncomment for optional default
  #/bin/echo "${optName[a]} option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${surfname} ${SOd} ${SOa}"

# Run the ink
. $InkRun
