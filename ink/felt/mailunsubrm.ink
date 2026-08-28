#!/bin/bash

# Set the serf name
surfname="inkmail"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This removes an address from the unsubscribe list.
EOU
)"

# Available flags
optSerf="d:e:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="Mail domain"
optName[e]="Email"
optDesc[e]="Address to remove"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
  ;;
  e)
    isEmail "${OPTARG}" "${optName[e]}"
    SOe="${OPTARG}"
  ;;
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
-e ${optName[e]}: ${optDesc[e]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} option must be set."; inkFail
fi
if [ -z "${SOe}" ]; then
  /bin/echo "${optName[e]} option must be set."; inkFail
fi

# Message prep
success_message="This removes an address from the unsubscribe list."
fail_message="Command failed."

# Prepare command
serfcommand="${Serfs}/inkmail unsubrm ${SOd} ${SOe}"

# Run the ink
. $InkRun
