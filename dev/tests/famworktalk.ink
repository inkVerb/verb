#!/bin/bash

# Set the serf name
SURFNAME="famworktalk"

# Include the settings & functions
source ${INKSET}
source ${iDir}/yeo.functions

# About message
aboutMsg="$(cat <<EOU
This is a family work routine that talks back.
EOU
)"

# If using isOption() Option Select
#validOptions=()

optSerf=":a:b:c:d:e:f:g:nh"
declare -A optName
declare -A optDesc
optName[a]=""
optDesc[a]=""
optName[b]=""
optDesc[b]=""
optName[c]=""
optDesc[c]=""
optName[d]=""
optDesc[d]=""
optName[e]=""
optDesc[e]=""
optName[f]=""
optDesc[f]=""
optName[g]=""
optDesc[g]=""
optDesc[n]=""

# Check the variables
while getopts "${optSerf}" Flag; do
 case $Flag in
  # Help
  h)
    SOh="true"
  ;;
  a)
    isaz "${OPTARG}"
    SOa="${OPTARG}"
  ;;
  b)
    isInt "${OPTARG}"
    SOb="${OPTARG}"
  ;;
  c)
    isDomain "${OPTARG}"
    SOc="${OPTARG}"
  ;;
  d)
    isDomain "${OPTARG}"
    SOd="${OPTARG}"
  ;;
  e)
    isDomain "${OPTARG}"
    SOe="${OPTARG}"
  ;;
  f)
    isDomain "${OPTARG}"
    SOf="${OPTARG}"
  ;;
  g)
    isDomain "${OPTARG}"
    SOg="${OPTARG}"
  ;;
  n)
    SOn="-n"
  ;;
 esac
done

# Check if help
if [ "${SOh}" = "true" ]; then
  echo "${aboutMsg}"
  echo "
  Flag settings:
  -a ${optName[a]} ${optDesc[a]}
  -b ${optName[b]} ${optDesc[b]}
  -c ${optName[c]} ${optDesc[c]}
  -d ${optName[d]} ${optDesc[d]}
  "
  exit 0
fi

# Check requirements or defaults
if [ -z "${SOa}" ]; then
  #SOa="DEFAULT" # Uncomment for optional default
  echo "${optName[a]} must be set."; yeoFail="true" # Uncomment if required
fi
if [ -z "${SOb}" ]; then
  #SOb="DEFAULT" # Uncomment for optional default
  echo "${optName[b]} must be set."; yeoFail="true" # Uncomment if required
fi
if [ -z "${SOc}" ]; then
  #SOc="DEFAULT" # Uncomment for optional default
  echo "${optName[c]} must be set."; yeoFail="true" # Uncomment if required
fi
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  echo "${optName[d]} must be set."; yeoFail="true" # Uncomment if required
fi
if [ -z "${SOe}" ]; then
  #SOe="DEFAULT" # Uncomment for optional default
  echo "${optName[e]} must be set."; yeoFail="true" # Uncomment if required
fi
if [ -z "${SOf}" ]; then
  #SOf="DEFAULT" # Uncomment for optional default
  echo "${optName[f]} must be set."; yeoFail="true" # Uncomment if required
fi
if [ -z "${SOg}" ]; then
  #SOg="DEFAULT" # Uncomment for optional default
  echo "${optName[g]} must be set."; yeoFail="true" # Uncomment if required
fi
if [ -z "${SOn}" ]; then
  SOn="-n" # Uncomment for optional default
  #echo "${optName[a]} must be set."; exit 0 # Uncomment if required
fi

# Exit if failed
if [ "${yeoFail}" = "true" ]; then
  echo "Learn more with: yeo ${ACTION} ${SCHEMA} -h"
  exit 0;
fi

"${Serfs}/${SURFNAME}" "${SOa}" "${SOb}" "${SOc}" "${SOd}" "${SOe}" "${SOf}" "${SOg}" "${SOn}"
