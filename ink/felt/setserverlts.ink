#!/bin/bash

# Set the serf name
surfname="setserverlts"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
Install Node 22 LTS for Ghost, isolated from pacman, and write /opt/verb/conf/serverlts
If Node 22 is already there, skip download. -f fetches the latest 22.x patch.
PHP is recorded, not pinned. Not run by ink update verber.
EOU
)"

# Available flags
optSerf="fhrcv"
declare -A optName
declare -A optDesc
optName[f]="Refresh"
optDesc[f]="Fetch latest Node 22.x even if major 22 is already installed"

# Check the variables
SOf=""
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  f)
    SOf="true"
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
-f ${optName[f]}: ${optDesc[f]}
"
  exit 0
fi

SOverbose="true"

# Message prep
success_message=""
fail_message="setserverlts failed."

# Prepare command
serfcommand="${Serfs}/${surfname}"
[ "${SOf}" = "true" ] && serfcommand="${serfcommand} refresh"

# Run the ink
. $InkRun
