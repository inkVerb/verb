#!/bin/bash

# Set the serf name
surfname="setbimi"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This moves a dropped BIMI SVG into www/html/domain.tld/bimi.svg and adds the DNS TXT.
inkMail uploads to /srv/vip/files/domain.tld.bimi.svg then runs this with -p vip.
EOU
)"

# Available flags
optSerf="d:p:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The hosted domain"
optName[p]="Drop path"
optDesc[p]="vip or ftp"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
  ;;
  p)
    isChoice "${OPTARG}" "vip ftp" "${optName[p]}"
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
-d ${optName[d]}: ${optDesc[d]}
-p ${optName[p]}: ${optDesc[p]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} option must be set."; inkFail
fi
if [ -z "${SOp}" ]; then
  /bin/echo "${optName[p]} option must be set."; inkFail
fi

# Message prep
success_message="This moves a dropped BIMI SVG into www/html/domain.tld/bimi.svg and adds the DNS TXT."
fail_message="Command failed."

# Prepare command
serfcommand="${Serfs}/${surfname} ${SOd} ${SOp}"

# Run the ink
. $InkRun
