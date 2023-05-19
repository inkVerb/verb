#!/bin/bash

# Set the serf name
SURFNAME="webvipcgi"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions
. ${Conf}/siteurilist

# Not for LEMP
forbiddenServerType LEMP

# About message
aboutMsg="$(cat <<EOU
This activates CGI for v.${vipURI}/cgi/
EOU
)"

# Available flags
optSerf="hynrcv"
declare -A optName
declare -A optDesc
optName[yn]="On/Off"
optDesc[yn]="Choose one-letter flag: -y=on -n=off"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
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

# Message prep
success_message="FTP folder vip/cgi active with CGI, hosted at: v.${vipURI}/cgi/"

# Fail message
fail_message="v.${vipURI} CGI failed to turn $SOyn"

# Check requirements or defaults
## Help
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

## Y/N
if [ -z "${SOyn}" ]; then
  /bin/echo "${optName[yn]}  option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOyn}"

# Run the ink
. $InkRun
