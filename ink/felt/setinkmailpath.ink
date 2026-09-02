#!/bin/bash

# Set the serf name
surfname="setinkmailpath"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This changes the URL folder of inkMail on po.emailTLDURI.
Updates verb/conf/servermailpath, /etc/inkmail/conf, and the nginx location.
EOU
)"

# Available flags
optSerf="p:hrcv"
declare -A optName
declare -A optDesc
optName[p]="Folder"
optDesc[p]="URL folder under po.emailTLDURI"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  p)
    isazAZ09lines "${OPTARG}" "${optName[p]}"
    SOp="${OPTARG}"
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
-p ${optName[p]}: ${optDesc[p]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOp}" ]; then
  /bin/echo "${optName[p]} option must be set."; inkFail
fi

# Message prep
success_message="inkMail URL folder updated."
fail_message="Command failed."

# Prepare command
serfcommand="${Serfs}/${surfname} ${SOp}"

# Run the ink
. $InkRun
