#!/bin/bash

# Set the serf name
surfname="wppagify"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
Convert WordPress posts to pages (MariaDB post_type).
-d domain.tld finds vapp.wp.DOMAIN. -v is verbose (not a vapp).
-p, -g, and -a are exclusive.
EOU
)"

# Available flags (-v is ink verbose, like every other felt)
optSerf="d:p:gahrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="Hosted domain; uses vapp.wp.DOMAIN"
optName[p]="Post ID"
optDesc[p]="Convert this post ID to a page"
optName[g]="Get IDs"
optDesc[g]="Tab-separated Title, slug, ID of posts"
optName[a]="All"
optDesc[a]="Convert every post to a page"

# Check the variables
SOd=""
SOp=""
SOg=""
SOa=""
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
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
-p ${optName[p]}: ${optDesc[p]}
-g ${optName[g]}: ${optDesc[g]}
-a ${optName[a]}: ${optDesc[a]}
-v Verbose (serf stdout to the terminal)
"
  exit 0
fi

if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} option must be set."; inkFail
fi

## Exclusive action: -p, -g, or -a
nAct=0
[ -n "${SOp}" ] && nAct=$((nAct + 1))
[ "${SOg}" = "true" ] && nAct=$((nAct + 1))
[ "${SOa}" = "true" ] && nAct=$((nAct + 1))
if [ "${nAct}" != "1" ]; then
  /bin/echo "Set exactly one of -p ID, -g, or -a."; inkFail
fi

# -g is a listing; hide it and the command is useless
if [ "${SOg}" = "true" ]; then
  SOverbose="true"
  success_message=""
else
  success_message="WordPress posts converted to pages on ${SOd}."
fi
fail_message="wppagify failed on ${SOd}."

# Prepare command (-d always resolves vapp.wp.DOMAIN)
serfcommand="${Serfs}/${surfname} domain ${SOd}"
if [ "${SOg}" = "true" ]; then
  serfcommand="${serfcommand} get"
elif [ "${SOa}" = "true" ]; then
  serfcommand="${serfcommand} all"
else
  serfcommand="${serfcommand} ${SOp}"
fi

# Run the ink
. $InkRun
