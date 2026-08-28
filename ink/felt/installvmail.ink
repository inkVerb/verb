#!/bin/bash

# Set the serf name
surfname="installinkvmail"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This installs Postfix vmail, Roundcube, and one po.emailURI mail admin (PFA default, or inkMail).
EOU
)"

# Available flags
optSerf="r:p:a:s:b:hcv"
declare -A optName
declare -A optDesc
optName[r]="Roundcube path"
optDesc[r]="The web path to access RoundCube"
optName[p]="po. path"
optDesc[p]="The web path on po.emailURI for PFA or inkMail"
optName[a]="Mail admin"
optDesc[a]="pfa (default, PostfixAdmin) or ima (inkMail)"
optName[s]="PostfixAdmin Setup password"
optDesc[s]="The password to setup PostfixAdmin (ignored for ima)"
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
   a)
     SOa="${OPTARG}"
   ;;
   s)
     isazAZ09 "${OPTARG}" "${optName[s]}" "n"
     SOs="${OPTARG}"
   ;;
   b)
     isBackupFile "${OPTARG}" "${optName[b]}" "n"
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
-a ${optName[a]}: ${optDesc[a]}
-b ${optName[b]}: ${optDesc[b]}
-p ${optName[p]}: ${optDesc[p]}
-r ${optName[r]}: ${optDesc[r]}
-s ${optName[s]}: ${optDesc[s]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOr}" ]; then
  SOr="$(/usr/bin/pwgen -0 5 1)"
fi
if [ -z "${SOp}" ]; then
  SOp="$(/usr/bin/pwgen -0 5 1)"
fi
if [ -z "${SOa}" ]; then
  SOa="pfa"
fi
case "${SOa}" in
  pfa|ima) ;;
  *)
    /bin/echo "${optName[a]} must be pfa or ima."
    inkFail
    ;;
esac
if [ -z "${SOs}" ]; then
  SOs="$(pwgen -1Bcn 10)"
fi

# Message prep
. /opt/verb/conf/siteurilist
if [ "${SOa}" = "ima" ]; then
success_message=$(
cat <<EOF
Inkvmail successfully installed!
RoundCube address: https://box.${emailTLDURI}/${SOr}
inkMail address: https://po.${emailTLDURI}/${SOp}/
EOF
)
else
success_message=$(
cat <<EOF
Inkvmail successfully installed!
RoundCube address: https://box.${emailTLDURI}/${SOr}
PostfixAdmin address: https://po.${emailTLDURI}/${SOp}
PostfixAdmin setup password: ${SOs}
PostfixAdmin setup address: https://po.${emailTLDURI}/${SOp}/setup.php
EOF
)
fi

# Fail message
fail_message="Inkvmail failed to be installed."


# Prepare command
serfcommand="${Serfs}/${surfname} ${SOr} ${SOp} ${SOa} ${SOs} ${SOb}"

# Run the ink
. $InkRun
