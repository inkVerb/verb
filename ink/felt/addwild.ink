#!/bin/bash

# Set the serf name
surfname="addwild"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This enables wildcard * hosting on a domain already added with add domain
Apache/Nginx keep domain.tld and *.domain.tld in the same .conf
The apex is not included by *.domain.tld alone
EOU
)"

# Available flags
optSerf="d:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The hosted domain to enable wildcard * on"

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
success_message="$SOd wildcard hosting added (apex + *.$SOd in the same site config)."

# Fail message
fail_message="$SOd wildcard hosting failed to be added."

## Required flags & defaults
if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} option must be set."; inkFail
fi

# Prepare command
serfcommand="${Serfs}/${surfname} ${SOd}"

# Run the ink
. $InkRun
