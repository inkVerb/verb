#!/bin/bash

# Set the serf name
surfname="adddomain"

# Include the settings & functions
. ${InkSet}
. ${iDir}/ink.functions

# About message
aboutMsg="$(cat <<EOU
This adds a new domain, complete with OpenDKIM profiles and keys and inkCert and Apache configs
This also creates a folder for the domain in www/domains which an ftpvip can access
This also creates an inkDNS zone file, complete with mail records
EOU
)"

# Available flags
optSerf="d:nmswhrcv"
declare -A optName
declare -A optDesc
optName[d]="Domain"
optDesc[d]="A new domain (or subdomain if using for email and unique SSL certificates)"
optName[n]="No cert (default, no certs yet)"
optDesc[n]="Do not obtain certs yet, plan to add subdomains with ink cert add subdomain; will require ink cert do -d domain.tld when finished"
optName[m]="Multiple (standard, no subdomains for now)"
optDesc[m]="Obtain certs immediately for only this domain, allow multiple subdomains in the cert for this parent domain in the future"
optName[s]="Single"
optDesc[s]="Obtain a single cert, subdomains and parent domains use this flag each to obtain their own certs"
optName[w]="Wildcard"
optDesc[w]="Obtain a wildcard subdomain cert, useful for the parent domain and all subdomains; requires verber set as self-parking nameserver"

# Check the variables
while getopts "${optSerf}" Flag; do
 case "${Flag}" in
  d)
    isDomain "${OPTARG}" "${optName[d]}"
    SOd="${OPTARG}"
  ;;
  n)
    SOcertarg="nocert"
  ;;
  m)
    SOcertarg="multi"
  ;;
  s)
    SOcertarg="single"
  ;;
  w)
    SOcertarg="wild"
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
-d ${optName[d]}: ${optDesc[d]}
"
  exit 0
fi

# Message prep
# Success message
success_message="$SOd domain added."

# Fail message
fail_message="$SOd domain failed to be added."

## Required flags & defaults
if [ -z "${SOd}" ]; then
  #SOd="DEFAULT" # Uncomment for optional default
  /bin/echo "${optName[d]} option must be set."; inkFail # Uncomment if required
fi
## Required flags & defaults
if [ -z "${SOcertarg}" ]; then
  SOcertarg="nocert" # Uncomment for optional default
fi

# Prepare command
serfcommand="${Serfs}/${surfname} ${SOd} ${SOa}"

# Run the ink
. $InkRun
