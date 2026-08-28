#!/bin/bash

# Set the serf name
surfname="installverbadmin"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This installs the verb web UI on vipURI. Refuses unless VERBvip=true was set before inst/setup.
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
success_message="This installs the verb web UI on vipURI. Refuses unless VERBvip=true was set before inst/setup."
fail_message="Command failed."

# Prepare command
serfcommand="${Serfs}/${surfname}"

# Run the ink
. $InkRun
