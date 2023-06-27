#!/bin/bash

# Set the serf name
surfroot="inkcertundo"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This removes Letsencrypt SSL certs obtained using inkCert.
EOU
)"

# Available flags
optSerf="d:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The domain (or parent domain, not subdomain) to remove certs for"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
  ;;
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
-d ${optName[d]}: ${optDesc[d]}
"
  exit 0
fi

# Which engine?
inkCertSiteStatus
inkCertServerConfStatus
if [ "$inkCertSiteStatus" = "Letsencrypt multiple" ] && [ "$inkCertServerConfStatus" = "Letsencrypt multiple" ]; then
  ENGINE="le"
elif [ "$inkCertSiteStatus" = "Letsencrypt single" ] && [ "$inkCertServerConfStatus" = "Letsencrypt single" ]; then
  ENGINE="cbsingle"
elif [ "$inkCertSiteStatus" = "Letsencrypt wildcard" ] && [ "$inkCertServerConfStatus" = "Letsencrypt wildcard" ]; then
  ENGINE="cb"
else
  /bin/echo "Something is broken. Domain uses $inkCertSiteStatus, but server conf uses $inkCertServerConfStatus."
  inkFail
fi

# Message prep
# Success message
success_message="$SOd cert removed."

# Fail message
fail_message="$SOd cert failed to be removed."

## Required flags & defaults
if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} or ${optName[d]} must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${surfroot}${ENGINE} ${SOd}"

# Run the ink
. $InkRun
