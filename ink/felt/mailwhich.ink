#!/bin/bash

# Set the serf name
surfname="inkmail"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This prints which mail stack is installed (inkemail or inkvmail).
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
success_message="This prints which mail stack is installed (inkemail or inkvmail)."
fail_message="Command failed."

# Prepare command
serfcommand="${Serfs}/inkmail which"

# Run the ink
. $InkRun
