#!/bin/bash

# Set the serf name
SURFNAME="mysqlnewdb"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This creates a new MySQL/MariaDB database with a specified new or existing user.
EOU
)"

# Available flags
optSerf="d:u:p:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Database"
optDesc[d]="The new database to be creeated"
optName[u]="Username"
optDesc[u]="The username being added, and created if new; if not specified, the database name will be atttempted for the username"
optName[p]="Optional Password"
optDesc[p]="The optional password for the user"

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
success_message="Database '$SOu' created for user ${SOu}."

# Fail message
fail_message="Database '$SOu' failed to be created for user ${SOu}."

# Check requirements or defaults
## Help
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
if [ -z "${SOu}" ]; then
  isSQLUserCredential ${SOd} "Database user"
  [[ $isSQLUserCredential = "true" ]] && SOu="${SOd}" # Uncomment for optional default
  #/bin/echo "${optName[u]} option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOd} ${SOu} ${SOp}"

# Run the ink
. $InkRun
