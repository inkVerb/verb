#!/bin/bash

# Set the serf name
surfname="wpurl"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
Rewrite a WordPress site URL in wp-config.php and the whole database
(serialized PHP, JSON, posts, media, options).
-d is the hosted domain only (church.jesse.house), not https://
-o old public URL (https://jesse.church)
-t new public URL (https://church.jesse.house)
Old URL must match WP_HOME / WP_SITEURL (or wp-config already has the new URL).
-v is verbose (not a vapp).
EOU
)"

# Available flags (-v is ink verbose, like every other felt)
optSerf="d:o:t:nhrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="Hosted domain only, no https:// (vapp.wp.DOMAIN)"
optName[o]="Old URL"
optDesc[o]="Current public URL, e.g. https://jesse.church"
optName[t]="To URL"
optDesc[t]="New public URL, e.g. https://church.jesse.house"
optName[n]="Dry run"
optDesc[n]="Print what would change; no writes"

# Check the variables
SOd=""
SOo=""
SOt=""
SOn=""
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
  ;;
  o)
    oArg="${OPTARG}"
    [[ "${oArg}" != *"://"* ]] && oArg="https://${oArg}"
    isURL "${oArg}" "${optName[o]}"
    SOo="${oArg}"
  ;;
  t)
    tArg="${OPTARG}"
    [[ "${tArg}" != *"://"* ]] && tArg="https://${tArg}"
    isURL "${tArg}" "${optName[t]}"
    SOt="${tArg}"
  ;;
  n)
    SOn="true"
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
-d ${optName[d]}: ${optDesc[d]}
-o ${optName[o]}: ${optDesc[o]}
-t ${optName[t]}: ${optDesc[t]}
-n ${optName[n]}: ${optDesc[n]}
-v Verbose (serf stdout to the terminal)
"
  exit 0
fi

if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} option must be set."; inkFail
fi
if [ -z "${SOo}" ]; then
  /bin/echo "${optName[o]} option must be set."; inkFail
fi
if [ -z "${SOt}" ]; then
  /bin/echo "${optName[t]} option must be set."; inkFail
fi

success_message="WordPress URL rewritten on ${SOd}."
fail_message="wpurl failed on ${SOd}."

serfcommand="${Serfs}/${surfname} ${SOo} ${SOt} -d ${SOd}"
[ "${SOn}" = "true" ] && serfcommand="${serfcommand} dry-run"

. $InkRun
