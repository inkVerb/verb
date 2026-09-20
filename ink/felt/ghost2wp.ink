#!/bin/bash

# Set the serf name
surfname="ghost2wp"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
Import Ghost posts, pages, menus, and media into WordPress on a hosted domain.
Ghost's MariaDB is read-only. WordPress must already be installed (ink install wp).
EOU
)"

# Available flags
optSerf="d:nmkhrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The hosted domain (Ghost source and WordPress destination)"
optName[n]="Dry run"
optDesc[n]="Print what would happen; no writes"
optName[m]="Media only"
optDesc[m]="Copy/register media only (posts already imported)"
optName[k]="Keep Ghost nginx"
optDesc[k]="Do not restore the pre-Ghost PHP vhost"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
  ;;
  n)
    SOn="true"
  ;;
  m)
    SOm="true"
  ;;
  k)
    SOk="true"
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
-n ${optName[n]}: ${optDesc[n]}
-m ${optName[m]}: ${optDesc[m]}
-k ${optName[k]}: ${optDesc[k]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} option must be set."; inkFail
fi

# Message prep
success_message="Ghost imported into WordPress on ${SOd}."
fail_message="Ghost import into WordPress failed on ${SOd}."

# Prepare command
serfcommand="${Serfs}/${surfname} ${SOd}"
[ "${SOn}" = "true" ] && serfcommand="${serfcommand} dry-run"
[ "${SOm}" = "true" ] && serfcommand="${serfcommand} media-only"
[ "${SOk}" = "true" ] && serfcommand="${serfcommand} keep-nginx"

# Run the ink
. $InkRun
