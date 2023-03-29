#!/bin/bash

# Set the serf name
SURFNAME="adddomainfiler"

# Include the settings & functions
. ${INKSET}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This adds an existing domain to an existing ftpfiler's home "~/domains" folder
EOU
)"

# Available flags
optSerf="d:f:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The domain to be activated"
optName[f]="FTP Filer"
optDesc[f]="The FTP user to gain folder access to the activated domain"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    isWWWdomain "${OPTARG}" "Hosted domain ${OPTARG}"
    SOd="${OPTARG}"
  ;;
  f)
    isFTPfiler "${OPTARG}" "${optName[f]}"
    SOf="${OPTARG}"
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

# Message prep
# Success message
success_message="$SOf added to $SOd."

# Fail message
fail_message="$SOf could not be added to $SOd."

# Check requirements or defaults
## HELP
if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}"
  /bin/echo "
Available flags:
-h This help message
-d ${optName[d]}: ${optDesc[d]}
-f ${optName[f]}: ${optDesc[f]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOf}" ]; then
  #SOf="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[f]} option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOd} ${SOf}"

# Run the ink
. $InkRun
