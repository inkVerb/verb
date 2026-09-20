#!/bin/bash

# Set the serf name
surfname="wpfitimages"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
Fit WordPress post/page images to the content width (max-width:100%; height:auto).
Uses vapp.wp.DOMAIN. Idempotent. Does not touch Ghost.
EOU
)"

# Available flags
optSerf="d:nhrc"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="Hosted domain (vapp.wp.DOMAIN)"
optName[n]="Dry run"
optDesc[n]="Print what would change; no writes"

# Check the variables
SOd=""
SOn=""
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
  ;;
  n)
    SOn="true"
  ;;
  c)
    SOcli="true"
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
-d ${optName[d]}: ${optDesc[d]}
-n ${optName[n]}: ${optDesc[n]}
"
  exit 0
fi

if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} option must be set."; inkFail
fi

SOverbose="true"
success_message=""
fail_message="wpfitimages failed on ${SOd}."

serfcommand="${Serfs}/${surfname} ${SOd}"
[ "${SOn}" = "true" ] && serfcommand="${serfcommand} dry-run"

. $InkRun
