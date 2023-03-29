#!/bin/bash

# Set the serf name
SURFNAME="webcgi"

# Include the settings & functions
. ${INKSET}
. ${iDir}/ink.functions

# Not for LEMP
forbiddenServerType LEMP

# About message
aboutMsg="$(cat <<EOU
This activates public access to read files in a hosted domain or subdomain
EOU
)"

# Available flags
optSerf="hd:ynorcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The hosted domain or subdomain to change the CGI option for"
optName[yn]="On/Off"
optDesc[yn]="Choose one-letter flag: -y=on -n=off"
optName[o]="Overwrite"
optDesc[o]="Required if .htaccess already exists, including if this command was used before"

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
  o)
    SOo="-o"
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
success_message="$SOd webfolder read access $SOyn"

# Fail message
fail_message="$SOd webfolder read access failed to turn $SOyn"

# Check requirements or defaults
## HELP
if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}"
  /bin/echo "
Available flags:
-h This help message
-d ${optName[d]} ${optDesc[d]}
-y/n  ${optName[yn]}: ${optDesc[yn]}
-o ${optName[o]} ${optDesc[o]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi

## Y/N
if [ -z "${SOyn}" ]; then
  /bin/echo "${optName[yn]}  option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOyn} ${SOd} ${SOo}"

# Run the ink
. $InkRun
