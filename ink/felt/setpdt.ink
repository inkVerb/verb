#!/bin/bash

# Set the serf name
surfname="setpdt"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This modifies settings for a pdt-news vapp already installed on a hosted domain
Writes verb/conf/vapps/pdt.DOMAIN.config and restarts the service
EOU
)"

# Available flags
optSerf="d:b:u:p:m:k:s:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The hosted domain where pdt-news is installed"
optName[b]="Database"
optDesc[b]="PostgreSQL database name (db_name)"
optName[u]="Database user"
optDesc[u]="PostgreSQL user (db_user)"
optName[p]="Database password"
optDesc[p]="PostgreSQL password (db_pass)"
optName[m]="Mode"
optDesc[m]="single or network"
optName[k]="Config key"
optDesc[k]="Any config key (mode, web_url, theme, ...)"
optName[s]="Setting value"
optDesc[s]="Value for -k"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
  ;;
  b)
    isSQLDatabasename "${OPTARG}" "${optName[b]}"
    SOb="${OPTARG}"
  ;;
  u)
    isSQLDatabasename "${OPTARG}" "${optName[u]}"
    SOu="${OPTARG}"
  ;;
  p)
    isSQLDatabasename "${OPTARG}" "${optName[p]}" "n"
    SOp="${OPTARG}"
  ;;
  m)
    isChoice "${OPTARG}" "single network" "${optName[m]}"
    SOm="${OPTARG}"
  ;;
  k)
    isazAZ09lines "${OPTARG}" "${optName[k]}" "n"
    SOk="${OPTARG}"
  ;;
  s)
    isGraphChar "${OPTARG}" "${optName[s]}" "n"
    SOs="${OPTARG}"
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
-m ${optName[m]}: ${optDesc[m]}
-b ${optName[b]}: ${optDesc[b]}
-u ${optName[u]}: ${optDesc[u]}
-p ${optName[p]}: ${optDesc[p]}
-k ${optName[k]}: ${optDesc[k]}
-s ${optName[s]}: ${optDesc[s]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} option must be set."; inkFail
fi

# Message prep
success_message="pdt-news settings updated on ${SOd}."
fail_message="pdt-news settings failed to update on ${SOd}."

# Prepare command (key=value pairs so omitted flags do not shift)
serfcommand="${Serfs}/${surfname} ${SOd}"
[ -n "${SOm}" ] && serfcommand="${serfcommand} mode=${SOm}"
[ -n "${SOb}" ] && serfcommand="${serfcommand} db_name=${SOb}"
[ -n "${SOu}" ] && serfcommand="${serfcommand} db_user=${SOu}"
[ -n "${SOp}" ] && serfcommand="${serfcommand} db_pass=${SOp}"
[ -n "${SOk}" ] && serfcommand="${serfcommand} ${SOk}=${SOs}"

# Run the ink
. $InkRun
