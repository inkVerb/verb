#!/bin/bash

# Set the serf name
surfname="newverbadmin"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This creates a nologin PAM user for the verb web UI (groups verb + admin|supervisor).
SQL meta is a redundant cross-check. The web UI cannot create other admins.
EOU
)"

# Available flags
optSerf="u:t:e:hrcv"
declare -A optName
declare -A optDesc
optName[u]="Username"
optDesc[u]="Linux username (nologin, no home, no sudo)"
optName[t]="Account type"
optDesc[t]="admin or supervisor"
optName[e]="Email"
optDesc[e]="Email for codes/links and confirmation"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  u)
    isUsername "${OPTARG}" "${optName[u]}"
    SOu="${OPTARG}"
  ;;
  t)
    isChoice "${OPTARG}" "admin supervisor" "${optName[t]}"
    SOt="${OPTARG}"
  ;;
  e)
    isEmail "${OPTARG}" "${optName[e]}"
    SOe="${OPTARG}"
  ;;
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
-t ${optName[t]}: ${optDesc[t]}
-e ${optName[e]}: ${optDesc[e]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOu}" ]; then
  /bin/echo "${optName[u]} option must be set."; inkFail
fi
if [ -z "${SOt}" ]; then
  /bin/echo "${optName[t]} option must be set."; inkFail
fi
if [ -z "${SOe}" ]; then
  /bin/echo "${optName[e]} option must be set."; inkFail
fi

# Message prep
success_message="This creates a nologin PAM user for the verb web UI (groups verb + admin|supervisor)."
fail_message="Command failed."

# Prepare command
serfcommand="${Serfs}/${surfname} ${SOu} ${SOt} ${SOe}"

# Run the ink
. $InkRun
