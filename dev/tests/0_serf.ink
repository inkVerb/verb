#!/bin/bash

# Set the serf name
SURFNAME="serfname"

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

# Available flags
optSerf="a:b:c:d:e:f:g:i:j:k:l:m:o:p:q:hynr"
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
optName[i]=""
optDesc[i]=""
optName[j]=""
optDesc[j]=""
optName[k]=""
optDesc[k]=""
optName[l]=""
optDesc[l]=""
optName[m]=""
optDesc[m]=""
optName[o]=""
optDesc[o]=""
optName[p]=""
optDesc[p]=""
optName[q]=""
optDesc[q]=""
optName[n]=""
optDesc[n]=""
optName[r]="Richtext response"
optDesc[r]="use HTML vsuccess/verror classes (success/error)"
optName[yn]="Yes/No"
optDesc[yn]="Choose one-letter flag: (y)es or (n)o"


# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  # Help
  h)
    SOh="true"
  ;;
  a)
    isTEST "${OPTARG}" "${optName[a]}"
    SOa="${OPTARG}"
  ;;
  b)
    isTEST "${OPTARG}" "${optName[b]}"
    SOb="${OPTARG}"
  ;;
  c)
    isTEST "${OPTARG}" "${optName[c]}"
    SOc="${OPTARG}"
  ;;
  d)
    isTEST "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
  ;;
  e)
    isTEST "${OPTARG}" "${optName[e]}"
    SOe="${OPTARG}"
  ;;
  f)
    isTEST "${OPTARG}" "${optName[f]}"
    SOf="${OPTARG}"
  ;;
  g)
    isTEST "${OPTARG}" "${optName[g]}"
    SOg="${OPTARG}"
  ;;
  i)
    isTEST "${OPTARG}" "${optName[i]}"
    SOi="${OPTARG}"
  ;;
  j)
    isTEST "${OPTARG}" "${optName[j]}"
    SOj="${OPTARG}"
  ;;
  k)
    isTEST "${OPTARG}" "${optName[k]}"
    SOk="${OPTARG}"
  ;;
  l)
    isTEST "${OPTARG}" "${optName[l]}"
    SOl="${OPTARG}"
  ;;
  m)
    isTEST "${OPTARG}" "${optName[m]}"
    SOm="${OPTARG}"
  ;;
  o)
    isTEST "${OPTARG}" "${optName[o]}"
    SOo="${OPTARG}"
  ;;
  p)
    isTEST "${OPTARG}" "${optName[p]}"
    SOp="${OPTARG}"
  ;;
  q)
    isTEST "${OPTARG}" "${optName[q]}"
    SOq="${OPTARG}"
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
  r)
    richtext="true"
  ;;
  *)
    inkFail
  ;;
 esac
done

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


# Check requirements or defaults
## HELP
if [ "${SOh}" = "true" ]; then
  echo "
${aboutMsg}"
  echo "
Available flags:
-h This help message
-a  ${optName[a]}: ${optDesc[a]}
-b  ${optName[b]}: ${optDesc[b]}
-c  ${optName[c]}: ${optDesc[c]}
-d  ${optName[d]}: ${optDesc[d]}
-e  ${optName[e]}: ${optDesc[e]}
-f  ${optName[f]}: ${optDesc[f]}
-g  ${optName[g]}: ${optDesc[g]}
-i  ${optName[i]}: ${optDesc[i]}
-j  ${optName[j]}: ${optDesc[j]}
-k  ${optName[k]}: ${optDesc[k]}
-l  ${optName[l]}: ${optDesc[l]}
-m  ${optName[m]}: ${optDesc[m]}
-o  ${optName[o]}: ${optDesc[o]}
-p  ${optName[p]}: ${optDesc[p]}
-q  ${optName[q]}: ${optDesc[q]}
-y/n  ${optName[yn]}: ${optDesc[yn]}
-r  ${optName[r]}: ${optDesc[r]}
"
  exit 0
fi

## FLAGS
if [ -z "${SOa}" ]; then
  #SOa="DEFAULT" # Uncomment for optional default
  echo "${optName[a]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOb}" ]; then
  #SOb="DEFAULT" # Uncomment for optional default
  echo "${optName[b]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOc}" ]; then
  #SOc="DEFAULT" # Uncomment for optional default
  echo "${optName[c]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOe}" ]; then
  #SOe="DEFAULT" # Uncomment for optional default
  echo "${optName[e]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOf}" ]; then
  #SOf="DEFAULT" # Uncomment for optional default
  echo "${optName[f]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOg}" ]; then
  #SOg="DEFAULT" # Uncomment for optional default
  echo "${optName[g]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOi}" ]; then
  #SOa="DEFAULT" # Uncomment for optional default
  echo "${optName[i]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOj}" ]; then
  #SOb="DEFAULT" # Uncomment for optional default
  echo "${optName[j]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOk}" ]; then
  #SOc="DEFAULT" # Uncomment for optional default
  echo "${optName[k]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOl}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  echo "${optName[l]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOm}" ]; then
  #SOe="DEFAULT" # Uncomment for optional default
  echo "${optName[m]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOo}" ]; then
  #SOf="DEFAULT" # Uncomment for optional default
  echo "${optName[o]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOp}" ]; then
  #SOg="DEFAULT" # Uncomment for optional default
  echo "${optName[p]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOq}" ]; then
  #SOg="DEFAULT" # Uncomment for optional default
  echo "${optName[q]} option must be set."; inkFail # Uncomment if required
fi

## Y/N requirements
if [ -z "${SOyn}" ]; then
  #SOyn="-y" # Uncomment for optional YES default
  #SOyn="-n" # Uncomment for optional NO default
  echo "${optName[yn]} option must be set."; inkFail # Uncomment if required
fi
if [ -n $yes ] && [ -n $no ]; then
  inkFail
fi

## -n flag
if [ -z "${SOn}" ]; then
  SOn="" # Uncomment for optional default
  #echo "${optName[a]} must be set."; exit 0 # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOa} ${SOb} ${SOc} ${SOd} ${SOe} ${SOf} ${SOg} ${SOi} ${SOj} ${SOk} ${SOl} ${SOm} ${SOo} ${SOp} ${SOq} ${SOyn} ${SOn}"

# Run the ink
. $InkRun
