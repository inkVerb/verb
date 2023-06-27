#!/bin/bash

# Set the serf name
surfname="killsubdomain"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This removes a subdomain added with:
  # ink add subdomain
EOU
)"

# Available flags
optSerf="d:s:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The domain that the subdomain belongs to (this can be a higher subdomain)"
optName[s]="Subdomain"
optDesc[s]="The part of the name that makes it a subdomain (no periods)"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isWWWdomain "${OPTARG}" "Hosted domain ${OPTARG}" n
    SOd="${OPTARG}"
  ;;
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

# Check requirements or defaults
## Help
if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}"
  /bin/echo "
Available flags:
-h This help message
-d ${optName[d]}: ${optDesc[d]}
-s ${optName[s]}: ${optDesc[s]}
"
  exit 0
fi

# Message prep
# Success message
success_message="$SOs subdomain removed from $SOd domain."
# Fail messages
fail_message="$SOs subdomain could not be removed from $SOd domain."

# Special double-check the final result
isDomain "${SOs}.${SOd}" "Full length of the domain-to-be"

## Required flags & defaults
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${surfname} ${SOs} ${SOd}"

# Run the ink
. $InkRun
