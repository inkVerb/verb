#!/bin/bash

# Set the serf name
SURFNAME="actionsub"

# Include the settings & functions
. ${INKSET}
. ${iDir}/ink.functions
. ${Conf}/siteurilist
. ${Conf}/servernameip

# Not for LEMP
# forbiddenServerType LEMP

# About message
aboutMsg="$(cat <<EOU
About message here
EOU
)"

# If using isOption() Option Select
#validOptions=()

optSerf=":a:b:d:e:f:g:yncvhr"
declare -A optName
declare -A optDesc
optName[a]=""
optDesc[a]=""
optName[b]=""
optDesc[b]=""
optName[d]="Domain"
optDesc[d]="somedomain.tld"
optName[yn]=""
optDesc[yn]=""
optName[r]="Richtext response"
optDesc[r]="use HTML vsuccess/verror classes (success/error)"
optName[yn]="Yes/No"
optDesc[yn]="Choose one-letter flag: (y)es or (n)o"

# Check the variables
while getopts "${optSerf}" Flag; do
 case $Flag in
  a)
    isaz "${OPTARG}"
    SOa="${OPTARG}"
  ;;
  b)
    isInt "${OPTARG}"
    SOb="${OPTARG}"
  ;;
  d)
    isDomain "${OPTARG}"
    SOd="${OPTARG}"
  ;;
  y)
    SOyn="yes"
    yes="true"
  ;;
  n)
    SOyn="no"
    no="true"
    # OR
    SOn="-n"
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
. $INKOPT

# # Success message
# if $fail_log or $success_log are not set, they will default to $fail_message and $success_message respectively
# success_message="$(cat <<EOU
# Success message here
# EOU
# )"
# success_log="" # For log entries, if $success_message not set
#
# # Fail message
# fail_message="$(cat <<EOU
# Fail message here
# EOU
# )"
# fail_log="" # For log entries, if $fail_message not set

# Message prep
# Success message
success_message="$SOd domain Success message here"

# Fail message
fail_message="$SOd domain Fail message here"

# Check if help
if [ "${SOh}" = "true" ]; then
  echo "${aboutMsg}"
  echo "Available flags:
  -h This help message
  -a ${optName[a]} ${optDesc[a]}
  -b ${optName[b]} ${optDesc[b]}
  -d ${optName[d]} ${optDesc[d]}
  -y/n ${optName[yn]}: ${optDesc[yn]}
  -r ${optName[r]} ${optDesc[r]}
  "
  exit 0
fi

# Check requirements or defaults
if [ -z "${SOa}" ]; then
  #SOa="DEFAULT" # Uncomment for optional default
  echo "${optName[a]} must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOb}" ]; then
  #SOb="DEFAULT" # Uncomment for optional default
  echo "${optName[b]} must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOc}" ]; then
  #SOc="DEFAULT" # Uncomment for optional default
  echo "${optName[c]} must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  echo "${optName[d]} must be set."; inkFail # Uncomment if required
fi

## Y/N requirements
if [ -z "${SOyn}" ]; then
  #SOyn="-y" # Uncomment for optional YES default
  #SOyn="-n" # Uncomment for optional NO default
  echo "${optName[yn]} option must be set."; inkFail # Uncomment if required
fi
if [ -n "$yes" ] && [ -n "$no" ]; then
  inkFail
fi

## -n flag
if [ -z "${SOn}" ]; then
  SOn="" # Uncomment for optional default
  #echo "${optName[a]} must be set."; exit 0 # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOa} ${SOb} ${SOc} ${SOd} ${SOe} ${SOf} ${SOg} ${SOn}"

# Run the ink
. $InkRun
