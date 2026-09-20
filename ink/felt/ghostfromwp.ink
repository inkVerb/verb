#!/bin/bash

# Set the serf name
surfname="wp2ghost"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
Import WordPress posts, pages, tags, menus, and media into an installed Ghost site
WordPress is read-only. Ghost must already exist on the domain.
EOU
)"

# Available flags
optSerf="d:nmhrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="Hosted domain with both WordPress and Ghost"
optName[n]="Dry run"
optDesc[n]="Print what would happen; no writes"
optName[m]="Media only"
optDesc[m]="Copy media only"

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
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} option must be set."; inkFail
fi

# Message prep
success_message="WordPress imported into Ghost on ${SOd}."
fail_message="WordPress → Ghost import failed on ${SOd}."

# Prepare command
serfcommand="${Serfs}/${surfname} ${SOd}"
[ "${SOn}" = "true" ] && serfcommand="${serfcommand} dry-run"
[ "${SOm}" = "true" ] && serfcommand="${serfcommand} media-only"

# Run the ink
. $InkRun
