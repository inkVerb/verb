#!/bin/bash

# Set the serf name
SURFNAME="inkcertlist"

# Include the settings & functions
. ${INKSET}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This installs Letsencrypt and the inkCert framework for managing SSL certs on the server.
EOU
)"

# Available flags
optSerf="hrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The domain (or parent domain, not subdomain) to list child domains for"

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

# Message prep
# Success message
success_message="inkCert installed."

# Fail message
fail_message="inkCert failed to be installed."

# Check requirements or defaults
## HELP
if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}"
  /bin/echo "
Available flags:
-h This help message
"
  exit 0
fi

## Already installed?
inkCertInstallStatus
if [ $inkCertInstallStatus = "Installed" ]; then
  /bin/echo "inkCert already installed"; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME}"

# Run the ink
. $InkRun
