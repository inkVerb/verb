#!/bin/bash

# Alias: ink set pdt → setwinstonpress
surfname="setwinstonpress"

. ${InkSet}
. ${iDir}/ink.functions

aboutMsg="$(cat <<EOU
Alias of ink set winstonpress (was pdt-news)
EOU
)"

optSerf="d:b:u:p:m:k:s:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The hosted domain"
optName[b]="Database"
optDesc[b]="PostgreSQL database name"
optName[u]="Database user"
optDesc[u]="PostgreSQL user"
optName[p]="Database password"
optDesc[p]="PostgreSQL password"
optName[m]="Mode"
optDesc[m]="single or network"
optName[k]="Config key"
optDesc[k]="Any config key"
optName[s]="Setting value"
optDesc[s]="Value for -k"

while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d) isDomain "${OPTARG}" "${optName[d]}"; SOd="${OPTARG}" ;;
  b) isSQLDatabasename "${OPTARG}" "${optName[b]}"; SOb="${OPTARG}" ;;
  u) isSQLDatabasename "${OPTARG}" "${optName[u]}"; SOu="${OPTARG}" ;;
  p) isSQLDatabasename "${OPTARG}" "${optName[p]}" "n"; SOp="${OPTARG}" ;;
  m) isChoice "${OPTARG}" "single network" "${optName[m]}"; SOm="${OPTARG}" ;;
  k) isazAZ09lines "${OPTARG}" "${optName[k]}" "n"; SOk="${OPTARG}" ;;
  s) isGraphChar "${OPTARG}" "${optName[s]}" "n"; SOs="${OPTARG}" ;;
  c) SOcli="true" ;;
  v) SOverbose="true" ;;
  h) SOh="true" ;;
  r) richtext="true" ;;
  *) inkFail ;;
 esac
done

if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}
Use: ink set winstonpress -d domain.tld
"
  exit 0
fi
if [ -z "${SOd}" ]; then
  /bin/echo "${optName[d]} option must be set."; inkFail
fi

success_message="Winston Press settings updated on ${SOd}."
fail_message="Winston Press settings failed to update on ${SOd}."
serfcommand="${Serfs}/${surfname} ${SOd}"
[ -n "${SOm}" ] && serfcommand="${serfcommand} mode=${SOm}"
[ -n "${SOb}" ] && serfcommand="${serfcommand} db_name=${SOb}"
[ -n "${SOu}" ] && serfcommand="${serfcommand} db_user=${SOu}"
[ -n "${SOp}" ] && serfcommand="${serfcommand} db_pass=${SOp}"
[ -n "${SOk}" ] && serfcommand="${serfcommand} ${SOk}=${SOs}"
. $InkRun
