#!/bin/bash

# Set the serf name
SURFNAME="mysqlin"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This imports a MySQL/MariaDB database.
EOU
)"

# Available flags
optSerf="d:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Database"
optDesc[d]="The database to import"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
   d)
     isSQLDatabasename "${OPTARG}" "${optName[d]}"
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

# Message prep
# Success message
success_message="Database '$SOd' imported."

# Fail message
fail_message="Database '$SOd' failed to import."

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

## Required flags & defaults
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOd}"

# Run the ink
. $InkRun
