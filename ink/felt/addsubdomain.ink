#!/bin/bash

# Set the serf name
SURFNAME="addsubdomain"

# Include the settings & functions
. ${INKSET}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This adds a subdomain to a domain already hosted
This subdomain will not have unique email, DKIM keys, or SSL certs
This subdomain will "administratively" belong to the domain
The domain can have a "subdomain-like" format, such as:
- Domain: inkisaverb.com
- Subdomain: sub.inkisaverb.com
OR
- Domain: sub.inkisaverb.com (if this is a hosted domain with its own email, DKIM keys, SSL certs, etc)
- Subdomain: moresub.sub.inkisaverb.com
EOU
)"

# Available flags
optSerf="d:s:hrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="The domain that the subdomain belongs to (this can be a higher subdomain)"
optName[s]="Subdomain"
optDesc[s]="The part of the name that makes it a subdomain (no periods)"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isWWWdomain "${OPTARG}" "Hosted domain ${OPTARG}" n
    SOd="${OPTARG}"
  ;;
  s)
    isDomainPart "${OPTARG}" "${optName[s]}"
    SOs="${OPTARG}"
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

# Message prep
inkCertSiteStatus $SOd
# Success message
if [ $inkCertSiteStatus = "Letsencrypt multiple" ]; then
  success_message="$SOs subdomain added to $SOd domain. $SOd already uses $inkCertSiteStatus multiple SSL certs, so they will need to be updated."
elif [ $inkCertSiteStatus = "Letsencrypt wildcard" ]; then
  success_message="$SOs subdomain added to $SOd domain. $SOd already uses $inkCertSiteStatus SSL certs, so they should be automatically set up."
elif [ $inkCertSiteStatus = "Letsencrypt single" ]; then
  success_message="$SOs subdomain added to $SOd domain. $SOd uses a single-domain $inkCertSiteStatus SSL cert, so a $inkCertSiteStatus cert needs to be added for this also."
elif [ $inkCertSiteStatus = "Removed" ] || [ $inkCertSiteStatus = "Not yet" ]; then
  success_message="$SOs subdomain added to $SOd domain. $SOd has no SSL certs installed and is ready when you are."
elif [ $inkCertSiteStatus = "Self-Cert" ]; then
  success_message="$SOs subdomain added to $SOd domain. $SOd and its subdomains use SSL Self-certs."
elif [ $inkCertSiteStatus = "NA" ]; then
  success_message="$SOs subdomain added to $SOd domain. SSL certificates to not apply to $SOd and its subdomains."
else
  success_message="$SOs subdomain added to $SOd domain."
fi

# Fail message
fail_message="$SOs subdomain could not be added to $SOd domain."

# Special double-check the final result
isDomain "${SOs}.${SOd}" "Full length of the domain-to-be"

# Check requirements or defaults
## HELP
if [ "${SOh}" = "true" ]; then
  /bin/echo "
${aboutMsg}"
  /bin/echo "
Available flags:
-h This help message
-d ${optName[d]}: ${optDesc[d]}
-s ${optName[s]}: ${optDesc[s]}
"
  exit 0
fi

## Required flags & defaults
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi

# Prepare command
serfcommand="${Serfs}/${SURFNAME} ${SOs} ${SOd}"

# Run the ink
. $InkRun
