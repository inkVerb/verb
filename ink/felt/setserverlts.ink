#!/bin/bash

# Set the serf name
surfname="setserverlts"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
Install Node 22 LTS for Ghost, isolated from pacman, and write /opt/verb/conf/serverlts
Rewrites Ghost systemd units to use that Node. PHP is recorded, not pinned.
EOU
)"

# Available flags
optSerf="hrcv"
declare -A optName
declare -A optDesc

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
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
"
  exit 0
fi

# Message prep
success_message="Node LTS installed and serverlts written."
fail_message="setserverlts failed."

# Prepare command
serfcommand="${Serfs}/${surfname}"

# Run the ink
. $InkRun
