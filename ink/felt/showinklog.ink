#!/bin/bash

# Set the serf name
surfname="showinklog"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This pages the ink CLI raw serf output log (outputlog). Space page down, b page up, q quit. Starts at the end.
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

## Required flags & defaults


# Message prep
# Empty success so ink.run does not print after less quits
success_message=""
fail_message="Could not page the ink output log."

# Prepare command
serfcommand="${Serfs}/${surfname}"

# Run the ink
. $InkRun
