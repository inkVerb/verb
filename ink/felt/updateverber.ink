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

# Hidden flags: -c print command, -v serf stdout (same as every ink felt).
# Default is quiet: only the new Verno after success.

# Message prep
success_message=""
fail_message="updateverber failed."

# Prepare command
serfcommand="${Serfs}/${surfname}"

# Run the ink
. $InkRun

if [ "${vsuccess}" = "true" ] && [ -f /opt/verb/conf/inklists/verberverno ]; then
  . /opt/verb/conf/inklists/verberverno
  /usr/bin/echo "Verber at v${Verno}."
fi
