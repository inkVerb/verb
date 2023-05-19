#!/bin/bash

# Set the serf name
SURFNAME="mysqlvappin"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This imports a MySQL/MariaDB database for a given Verb web app.
EOU
)"

# Available flags
optSerf="a:hrcv"
declare -A optName
declare -A optDesc
optName[a]="App"
optDesc[a]="The Verb web app to import the database and credentials for"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
   a)
     isVappConfig "${OPTARG}" "${optName[a]}"
     SOa="${OPTARG}"
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
success_message="Verb web app '$SOa' imported."

# Fail message
fail_message="Verb web app '$SOa' failed to be imported."

# Check requirements or defaults
## Help
if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}"
  /bin/echo "
Available flags:
-h This help message
-a ${optName[a]}: ${optDesc[a]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOa}" ]; then
  #SOa="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[a]} option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOa}"

# Run the ink
. $InkRun
