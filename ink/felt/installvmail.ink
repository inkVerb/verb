#!/bin/bash

# Set the serf name
surfname="installinkvmail"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This creates a new MySQL/MariaDB admin user.
EOU
)"

# Available flags
optSerf="r:p:s:b:hrcv"
declare -A optName
declare -A optDesc
optName[r]="Roundcube path"
optDesc[r]="The web path to access RoundCube"
optName[p]="PostfixAdmin path"
optDesc[p]="The web path to access PostfixAdmin"
optName[s]="PostfixAdmin Setup password"
optDesc[s]="The password to setup PostfixAdmin"
optName[b]="Backup file to restore"
optDesc[b]="The name of the vmail backup file to restore from: www/vip/verb.vmail.*.vbak"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
   r)
     isazAZ09lines "${OPTARG}" "${optName[r]}" "n"
     SOr="${OPTARG}"
   ;;
   p)
     isazAZ09lines "${OPTARG}" "${optName[p]}" "n"
     SOp="${OPTARG}"
   ;;
   s)
     isazAZ09 "${OPTARG}" "${optName[s]}" "n"
     SOs="${OPTARG}"
   ;;
   b)
     isBackupFile "${OPTARG}" "${optName[s]}" "n"
     SOb="${OPTARG}"
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

# Check requirements or defaults
## Help
if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}"
  /bin/echo "
Available flags:
-h This help message
-b ${optName[b]}: ${optDesc[b]}
-p ${optName[p]}: ${optDesc[p]}
-r ${optName[r]}: ${optDesc[r]}
-s ${optName[s]}: ${optDesc[s]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOr}" ]; then
  SOr="$(/usr/bin/pwgen -0 5 1)" # Set this in the ink file for the output message, uncomment for default
  #/bin/echo "${optName[r]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOp}" ]; then
  SOp="$(/usr/bin/pwgen -0 5 1)" # Set this in the ink file for the output message, uncomment for default
  #/bin/echo "${optName[p]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOs}" ]; then
  SOs="$(pwgen -1Bcn 10)" # Set this in the ink file for the output message, uncomment for default
  #/bin/echo "${optName[s]} option must be set."; inkFail # Uncomment if required
fi

# Message prep
# Success message
. /opt/verb/conf/siteurilist
success_message="Inkvmail successfully installed!\n
RoundCube address: https://box.${emailTLDURI}/${SOr}\n
PostfixAdmin address: https://po.${emailTLDURI}/${SOp}\n
PostfixAdmin setup password: ${SOs}"

# Fail message
fail_message="Inkvmail failed to be installed."


# Prepare command
serfcommand="${Serfs}/${surfname} ${SOr} ${SOp} ${SOs} ${SOb}"

# Run the ink
. $InkRun
