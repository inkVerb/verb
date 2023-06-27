#!/bin/bash

# Set the serf name
surfroot="inkcertdo"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This obtains and installs Letsencrypt SSL certs using inkCert.
EOU
)"

# Available flags
optSerf="ad:mswhrcv"
declare -A optName
declare -A optDesc
optName[a]="All verb domains"
optDesc[a]="Obtain certs for all verb.* domains hosted on the server"
optName[d]="Domain"
optDesc[d]="The domain (or parent domain, not subdomain) to obtain certs for"
optName[m]="Multiple"
optDesc[m]="Obtain certs with subdomains multiple into the cert for the parent domain"
optName[s]="Single"
optDesc[s]="Obtain a single cert, subdomains and parent domains use this flag each to obtain their own cert"
optName[w]="Wildcard"
optDesc[w]="Obtain a wildcard subdomain cert, useful for the parent domain and all subdomains"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  m)
    if [ -n "$ENGINE" ]; then
      /bin/echo "Choose either -m, -s, or -w flag"
      inkFail
    fi
    SOm="true"
    ENGINE="le"
  ;;
  s)
    if [ -n "$ENGINE" ]; then
      /bin/echo "Choose either -m, -s, or -w flag"
      inkFail
    fi
    SOs="true"
    ENGINE="cbsingle"
  ;;
  w)
    if [ -n "$ENGINE" ]; then
      /bin/echo "Choose either -m, -s, or -w flag"
      inkFail
    fi
    SOw="true"
    ENGINE="cb"
  ;;
  d)
    if [ -n "$suffix" ]; then
      /bin/echo "Choose either -a or -d flag"
      inkFail
    fi
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
    suffix=" $SOd"
  ;;
  a)
    if [ -n "$suffix" ]; then
      /bin/echo "Choose either -a or -d flag"
      inkFail
    fi
    SOd="Verb domains"
    suffix="-all-verbs"
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

# Status
# Message prep
# Success message
if [ "$SOd" != "Verb domains" ]; then
  inkCertSiteStatus $SOd
  inkCertServerConfStatus $SOd
  if [ "$inkCertSiteStatus" = "Letsencrypt multiple" ] && [ "$inkCertServerConfStatus" = "Letsencrypt multiple" ]; then
    REFRESHLEOPTION=" r"
    success_message="$SOd cert refreshed. Don't do this too often or you could be briefly suspended from obtaining new certs."
  elif [ "$inkCertSiteStatus" = "Letsencrypt single" ] && [ "$inkCertServerConfStatus" = "Letsencrypt single" ]; then
    /bin/echo "Already certed using $inkCertSiteStatus certs. Nothing to do."
    exit 0
  elif [ "$inkCertSiteStatus" = "Letsencrypt wildcard" ] && [ "$inkCertServerConfStatus" = "Letsencrypt wildcard" ]; then
    /bin/echo "Already certed using $inkCertSiteStatus certs. Nothing to do."
    exit 0
  elif [ "$inkCertSiteStatus" != "Not yet" ] && [ "$inkCertServerConfStatus" != "Not yet" ] && [ "$inkCertSiteStatus" != "Removed" ] && [ "$inkCertServerConfStatus" != "Removed" ]; then
    /bin/echo "Something is broken. Current status isn't set properly in the server conf and ini settings."
    inkFail
  else
    REFRESHLEOPTION=""
    success_message="$SOd cert obtained."
  fi
else
  REFRESHLEOPTION=""
  success_message="$SOd cert obtained."
fi

# Fail message
fail_message="$SOd cert failed to be obtained."

# Check requirements or defaults
## Help
if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}"
  /bin/echo "
Available flags:
-h This help message

Choose between -m -s -w flags, only one must be used
-c ${optName[m]}: ${optDesc[m]}
-s ${optName[s]}: ${optDesc[s]}
-w ${optName[w]}: ${optDesc[w]}

Choose between -a -d flags, only one must be used
-a ${optName[a]}: ${optDesc[a]}
-d ${optName[d]}: ${optDesc[d]}

"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOd}" ] && [ -z "${SOa}" ]; then
  /bin/echo "${optName[d]} or ${optName[d]} must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOm}" ] && [ -z "${SOs}" ] && [ -z "${SOw}" ]; then
  /bin/echo "${optName[m]} or ${optName[s]} or ${optName[w]} must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${surfroot}${ENGINE}${suffix}${REFRESHLEOPTION}"

# Run the ink
. $InkRun
