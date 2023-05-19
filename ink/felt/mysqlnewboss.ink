#!/bin/bash

# Set the serf name
SURFNAME="mysqlnewboss"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This creates a new MySQL/MariaDB admin user.
EOU
)"

# Available flags
optSerf="u:p:hrcv"
declare -A optName
declare -A optDesc
optName[u]="Username"
optDesc[u]="The username being created"
optName[p]="Optional Password"
optDesc[p]="The optional password for the user, which is both insecure and should be unnecessary with 'no password' login set; if not set, a random password will be crated"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
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
success_message="Admin user '$SOu' added."

# Fail message
fail_message="Admin user '$SOu' failed to be added."

# Check requirements or defaults
## Help
if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}"
  /bin/echo "
Available flags:
-h This help message
-u ${optName[u]}: ${optDesc[u]}
-p ${optName[p]}: ${optDesc[p]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOu}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[u]} option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOu} ${SOp}"

# Run the ink
. $InkRun
