#!/bin/bash

# Set the serf name
SURFNAME="mysqladdusr"

# Include the settings & functions
. ${INKSET}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This adds a new or existing MySQL/MariaDB user to an existing database.
EOU
)"

# Available flags
optSerf="d:u:p:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Database"
optDesc[d]="The database receiving the new user"
optName[u]="Username"
optDesc[u]="The username already existing or being created"
optName[p]="Optional Password"
optDesc[p]="The SQL optional password for the user if new"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
   d)
     isSQLDatabasename "${OPTARG}" "${optName[d]}"
     SOd="${OPTARG}"
   ;;
   u)
     isSQLUserCredential "${OPTARG}" "${optName[u]}"
     SOu="${OPTARG}"
   ;;
   p)
     isSQLUserCredential "${OPTARG}" "${optName[p]}"
     SOp="${OPTARG}"
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
success_message="User added to database '$SOu'."

# Fail message
fail_message="User failed to be added to database '$SOu'."

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

## Required flags & defaults
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOu}" ] && [ -n "${SOp}" ]; then
  #unset SOp
  /bin/echo "${optName[p]} may not be set unless ${optName[u]} is also set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOd} ${SOu} ${SOp}"

# Run the ink
. $InkRun
