#!/bin/bash

# Set the serf name
surfname="ghost2wpmedia"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
Copy Ghost media into the WordPress uploads folder and register it in the Media Library.
Pass -m to move files instead of copying (Ghost originals are then removed).
EOU
)"

# Available flags
optSerf="d:mhrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The hosted domain (Ghost source and WordPress destination)"
optName[m]="Move"
optDesc[m]="Move files instead of copying (Ghost originals are removed)"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
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
-m ${optName[m]}: ${optDesc[m]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} option must be set."; inkFail
fi

# Message prep
success_message="Ghost media imported into WordPress on ${SOd}."
fail_message="Ghost media import failed on ${SOd}."

# Prepare command
serfcommand="${Serfs}/${surfname} ${SOd}"
[ "${SOm}" = "true" ] && serfcommand="${serfcommand} move"

# Run the ink
. $InkRun
