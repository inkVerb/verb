#!/bin/bash

# Set the serf name
SURFNAME="newvipsub"

# Include the settings & functions
. ${INKSET}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This adds a new subdomain for YOURNAME.verb.vip.
EOU
)"

# Available flags
optSerf="s:hrcv"
declare -A optName
declare -A optDesc
optName[s]="Subdomain"
optDesc[s]="The new subdomain to add to your ...verb.vip sites"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  s)
    isDomainPart "${OPTARG}" "${optName[s]}"
    SOs="${OPTARG}"
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
success_message="$SOs subdomain added."

# Fail message
fail_message="$SOs subdomain failed to be added."

# Check requirements or defaults
## HELP
if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}"
  /bin/echo "
Available flags:
-h This help message
-s ${optName[s]}: ${optDesc[s]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOs}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[s]} option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOs}"

# Run the ink
. $InkRun
