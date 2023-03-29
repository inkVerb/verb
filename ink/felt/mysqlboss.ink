#!/bin/bash

# Set the serf name
SURFNAME="mysqlboss"

# Include the settings & functions
. ${INKSET}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This creates a new Linux user with sudo permissions.
EOU
)"

# Available flags
optSerf="u:hrcv"
declare -A optName
declare -A optDesc
optName[u]="Username"
optDesc[u]="The username being created"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
   u)
     isSQLUserCredential "${OPTARG}" "${optName[u]}"
     SOu="${OPTARG}"
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
# Messages not needed for simple SQL terminal entry
# Success log
success_log="Admin database user created."

# Fail log
fail_log="Admin database user failed to be created."

# Check requirements or defaults
## HELP
if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}"
  /bin/echo "
Available flags:
-h This help message
-d ${optName[d]}: ${optDesc[d]}
-u ${optName[u]}: ${optDesc[u]}
-p ${optName[p]}: ${optDesc[p]}
"
  exit 0
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOu}"

# Run the ink
. $InkRun
