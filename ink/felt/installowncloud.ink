#!/bin/bash

# Set the serf name
surfname="installowncloud"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This installs ownCloud OCIS on cab.blueURI (or cloud.blueURI with -s cloud)
EOU
)"

# Available flags
optSerf="s:hrcv"
declare -A optName
declare -A optDesc
optName[s]="Subdomain"
optDesc[s]="cab (default) or cloud"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  s)
    isChoice "${OPTARG}" "cab cloud" "${optName[s]}"
    SOs="${OPTARG}"
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

if [ -z "${SOs}" ]; then
  SOs="cab"
fi

success_message="ownCloud installed. Finish at https://${SOs}.blueURI/"
fail_message="ownCloud failed to install."

serfcommand="${Serfs}/${surfname} ${SOs}"

. $InkRun
