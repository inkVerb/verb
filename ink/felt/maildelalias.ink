#!/bin/bash

# Set the serf name
surfname="inkmail"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This deletes an alias from the installed mail stack.
EOU
)"

# Available flags
optSerf="u:d:hrcv"
declare -A optName
declare -A optDesc
optName[u]="Alias user"
optDesc[u]="Local part (no domain)"
optName[d]="Domain"
optDesc[d]="Mail domain"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  u)
    isaz09lines "${OPTARG}" "${optName[u]}"
    SOu="${OPTARG}"
  ;;
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
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
-u ${optName[u]}: ${optDesc[u]}
-d ${optName[d]}: ${optDesc[d]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOu}" ]; then
  /bin/echo "${optName[u]} option must be set."; inkFail
fi
if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} option must be set."; inkFail
fi

# Message prep
success_message="This deletes an alias from the installed mail stack."
fail_message="Command failed."

# Prepare command
serfcommand="${Serfs}/inkmail delalias ${SOu} ${SOd}"

# Run the ink
. $InkRun
