#!/bin/bash

# Set the serf name
surfroot="newftp"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This creates a new FTP user, either 'user', 'filer', or 'vip'.
EOU
)"

# Available flags
optSerf="u:p:t:hrcv"
declare -A optName
declare -A optDesc
optName[u]="Username"
optDesc[u]="The FTP username being created"
optName[p]="Password"
optDesc[p]="The password for the FTP user"
optName[t]="Type (optional, default 'user')"
optDesc[t]="Choose: 'user' (default), 'filer', or 'vip'"

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
    t)
      if [ "${OPTARG}" = 'user' ] || [ "${OPTARG}" = 'filer' ] || [ "${OPTARG}" = 'vip' ]
        SOt="${OPTARG}"
      else
        SOt="user"
      fi
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
-u ${optName[u]}: ${optDesc[u]}
-p ${optName[p]}: ${optDesc[p]}
-t ${optName[t]}: ${optDesc[t]}
"
  exit 0
fi

# Message prep
# Success message
success_message="$SOu FTP ${SOt} created."

# Fail message
fail_message="$SOu FTP ${SOt} failed to be created."

## Required flags & defaults
if [ -z "${SOu}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[u]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOp}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[p]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOt}" ]; then
  SOt="user" # Uncomment for optional default
  #/bin/echo "${optName[t]} option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${surfroot}${SOt} ${SOu} ${SOp}"

# Run the ink
. $InkRun
