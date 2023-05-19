#!/bin/bash

# Set the serf name
SURFROOT="killdomain"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This removes a domain added with:
  # ink add domain
This will leave web folders and the domain framework untouched unless using the -p (purge) flag.
EOU
)"

# Available flags
optSerf="d:phrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The domain to remove"
optName[p]="Purge"
optDesc[p]="No arguments, also removes all hosted folder contents"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
  ;;
  p)
   SUFFIX="hard"
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

# Hard/soft kill and message prep
if [ -n "${SUFFIX}" ] && [ "${SUFFIX}" = "hard" ]; then
  # Success message
  success_message="$SOd domain removed and hosted folder purged."

else
    SUFFIX="soft"
    # Success message
    success_message="$SOd domain removed; hosted folder remains."
fi
# Fail message
fail_message="$SOd domain failed to be removed."

# Check requirements or defaults
## Help
if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}"
  /bin/echo "
Available flags:
-h This help message
-d ${optName[d]}: ${optDesc[d]}
-p ${optName[p]}: ${optDesc[p]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFROOT}${SUFFIX} ${SOd}"

# Run the ink
. $InkRun
