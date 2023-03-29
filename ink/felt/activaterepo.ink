#!/bin/bash

# Set the serf name
SURFNAME="activaterepo"

# Include the settings & functions
. ${INKSET}
. ${iDir}/ink.functions
. ${Conf}/siteurilist

# About message
aboutMsg="$(cat <<EOU
This activates the repo.${vipURI} folder for availability on the web
-y	(repo.${vipURI} becomes a web-accessible folder)
-n	(repo.${vipURI} returns to a redirect to ${inkURI})
EOU
)"

# Available flags
optSerf="hynrcv"
declare -A optName
declare -A optDesc
optName[yn]="y/n"
optDesc[yn]="Choose one-letter flag: -y=on -n=off"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  y)
    SOyn="on"
    yes="true"
    SuccessMessage="VIP repo activated."
    FailMessage="VIP files repo to activate."
  ;;
  n)
    SOyn="off"
    no="true"
    SuccessMessage="VIP repo deactivated."
    FailMessage="VIP files repo to deactivate."
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
success_message=$SuccessMessage

# Fail message
fail_message=$FailMessage

# Check requirements or defaults
## HELP
if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}"
  /bin/echo "
Available flags:
-h This help message
-y/n  ${optName[yn]}: ${optDesc[yn]}
"
  exit 0
fi

## Y/N requirements
if [ -z "${SOyn}" ]; then
  /bin/echo "${optName[yn]}  option must be set."; inkFail # Uncomment if required
fi
if [ -n $yes ] && [ -n $no ]; then
  inkFail
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOyn}"

# Run the ink
. $InkRun
