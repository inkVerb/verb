#!/bin/bash

# Set the serf name
surfname="newinkdkim"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This creates a new Linux user with sudo permissions.
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
     isUsername "${OPTARG}" "${optName[u]}"
     SOu="${OPTARG}"
   ;;
   p)
     isPassword "${OPTARG}" "${optName[p]}"
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

# Message prep
# Success message
success_message="$SOu boss user created."

# Fail message
fail_message="$SOu boss user failed to be created."

## Required flags & defaults
if [ -z "${SOu}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[u]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOp}" ]; then
  SOp="$(pwgen -s1 38)" # Uncomment for optional default
  #/bin/echo "${optName[u]} option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${surfname} ${SOu} ${SOp}"

# Run the ink
. $InkRun
