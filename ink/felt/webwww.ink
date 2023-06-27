#!/bin/bash

# Set the serf name
surfname="webwww"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This sets the option for a 'www' subdomain forwarding for a hosted domain or subdomain on the server
If 'on', this will redirect 'www.exemple.tld' to 'example.tld'
EOU
)"

# Available flags
optSerf="hd:ynrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The hosted domain or subdomain to change the 'www' subdomain forwarding for"
optName[yn]="On/Off"
optDesc[yn]="Choose one-letter flag: -y=on -n=off"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
  ;;
  y)
    SOyn="on"
  ;;
  n)
    SOyn="off"
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
-d ${optName[d]} ${optDesc[d]}
-y/n ${optName[yn]}: ${optDesc[yn]}
"
  exit 0
fi

# Message prep
# Success message
success_message="$SOd www subdomain forwarding $SOyn"

# Fail message
fail_message="$SOd www subdomain forwarding failed to turn $SOyn"

## Required flags & defaults
if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi

## Y/N
if [ -z "${SOyn}" ]; then
  /bin/echo "${optName[yn]}  option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${surfname} ${SOyn} ${SOd}"

# Run the ink
. $InkRun
