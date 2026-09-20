#!/bin/bash

# Set the serf name
surfname="wppostify"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
Convert WordPress pages to posts (MariaDB post_type). Inverse of pagify.
-d domain.tld checks the hosted domain and vapp.wp.DOMAIN.
-v wp.domain.tld uses that vapp name. -p, -g, and -a are exclusive.
EOU
)"

# Available flags (-v is the vapp, not verbose)
optSerf="d:v:p:gahrc"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="Hosted domain; checks vapp.wp.DOMAIN"
optName[v]="Vapp"
optDesc[v]="WordPress vapp name (wp.domain.tld)"
optName[p]="Page ID"
optDesc[p]="Convert this page ID to a post"
optName[g]="Get IDs"
optDesc[g]="Tab-separated Title, slug, ID of pages"
optName[a]="All"
optDesc[a]="Convert every page to a post"

# Check the variables
SOd=""
SOvapp=""
SOp=""
SOg=""
SOa=""
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
  ;;
  v)
    isDomain "${OPTARG}" "${optName[v]}"
    SOvapp="${OPTARG}"
  ;;
  p)
    isInt "${OPTARG}" "${optName[p]}"
    SOp="${OPTARG}"
  ;;
  g)
    SOg="true"
  ;;
  a)
    SOa="true"
  ;;
  c)
    SOcli="true"
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
-p ${optName[p]}: ${optDesc[p]}
-g ${optName[g]}: ${optDesc[g]}
-a ${optName[a]}: ${optDesc[a]}
"
  exit 0
fi

## Exclusive target: -d or -v
nTarget=0
[ -n "${SOd}" ] && nTarget=$((nTarget + 1))
[ -n "${SOvapp}" ] && nTarget=$((nTarget + 1))
if [ "${nTarget}" != "1" ]; then
  /bin/echo "Set exactly one of -d domain.tld or -v wp.domain.tld."; inkFail
fi

## Exclusive action: -p, -g, or -a
nAct=0
[ -n "${SOp}" ] && nAct=$((nAct + 1))
[ "${SOg}" = "true" ] && nAct=$((nAct + 1))
[ "${SOa}" = "true" ] && nAct=$((nAct + 1))
if [ "${nAct}" != "1" ]; then
  /bin/echo "Set exactly one of -p ID, -g, or -a."; inkFail
fi

# Table / count must reach the terminal and the GUI (default ink hides serf stdout)
SOverbose="true"

# Message prep
if [ -n "${SOd}" ]; then
  targetLabel="${SOd}"
else
  targetLabel="${SOvapp}"
fi
if [ "${SOg}" = "true" ]; then
  success_message=""
else
  success_message="WordPress pages converted to posts on ${targetLabel}."
fi
fail_message="wppostify failed on ${targetLabel}."

# Prepare command
if [ -n "${SOd}" ]; then
  serfcommand="${Serfs}/${surfname} domain ${SOd}"
else
  serfcommand="${Serfs}/${surfname} vapp ${SOvapp}"
fi
if [ "${SOg}" = "true" ]; then
  serfcommand="${serfcommand} get"
elif [ "${SOa}" = "true" ]; then
  serfcommand="${serfcommand} all"
else
  serfcommand="${serfcommand} ${SOp}"
fi

# Run the ink
. $InkRun
