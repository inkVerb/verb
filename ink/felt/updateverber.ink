#!/bin/bash

# Set the serf name
surfname="updateverber"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This downloads and updates the Verber core: ink, serfs, donjon, conf/lib
Runs verb-update/update (version patches + Verno message). Does not run setserverlts.
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

# ink default hides serf stdout. This MUST dump verb-update/update (Verno line).
SOverbose="true"

# Message prep — dump already ends with "Verber at v…"
success_message=""
fail_message="updateverber failed."

# Prepare command
serfcommand="${Serfs}/${surfname}"

# Run the ink
. $InkRun
