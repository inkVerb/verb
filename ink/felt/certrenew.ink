#!/bin/bash

# Set the serf name
surfname="inkcertrenewcbleall"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This renews all Letsencrypt certs obtained using inkCert.
EOU
)"

# Available flags
optSerf="hrcv"
declare -A optName
declare -A optDesc

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
   # Standard flags
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
# Success message
success_message="inkCert certs renewed."

# Fail message
fail_message="inkCert certs failed to be renewed."

## Already installed?
inkCertInstallStatus
if [ "$inkCertInstallStatus" != "Installed" ]; then
  /bin/echo "inkCert not installed"; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${surfname}"

# Run the ink
. $InkRun
