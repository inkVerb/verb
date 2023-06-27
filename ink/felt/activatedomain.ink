#!/bin/bash

# Set the serf name
surfname="activatedomain"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This activates a hosted domain to work with either the FTP-accessible domains/ directory or a Vapp
EOU
)"

# Available flags
optSerf="d:v:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The domain to be activated"
optName[v]="Vapp"
optDesc[v]="\"Verb app\" (optional) for activating with a verb app"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    isWWWdomain "${OPTARG}" "Hosted domain ${OPTARG}"
    SOd="${OPTARG}"
    MessageDomain="${OPTARG}"
  ;;
  v)
    isInstalledVapp "${OPTARG}" "${optName[v]}"
    SOv="${OPTARG}"
    MessageTarget="${OPTARG}"
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
-v ${optName[v]}: ${optDesc[v]}
"
  exit 0
fi

# Message prep
if [ -n "$MessageTarget" ]; then
  SuccessMessage="$MessageDomain activated for $MessageTarget Vapp."
  FailMessage="$MessageDomain failed to activate for $MessageTarget Vapp."
else
  SuccessMessage="$MessageDomain activated in domains folder."
  FailMessage="$MessageDomain failed to activate in domains folder."
fi

# Success message
success_message=$SuccessMessage

# Fail message
fail_message=$FailMessage

## Required flags & defaults
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOv}" ]; then
  #SOv="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[v]} option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${surfname} ${SOd} ${SOv}"

# Run the ink
. $InkRun
