#!/bin/bash

# Set the serf name
surfname="updateverber"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This downloads and updates the Verber core: ink, serfs, donjon, conf/lib
Also runs setserverlts so Ghost stays on Node 22 LTS
Does not replace pacman -Syu
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
success_message="Verber core updated."
fail_message="updateverber failed."

# Prepare command
serfcommand="${Serfs}/${surfname}"

# Run the ink
. $InkRun
