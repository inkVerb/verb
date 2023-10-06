#!/bin/bash
#inkVerbInk! verb.ink

# This passes on all arguments verbatim to yay, run by the "worker" user
## The purpose is to ensure that the task is always run by a non-root user, but doesn't prompt for passwords

# This requires normal users to run as "sudo"

# Usage: run "yeo" instead of "yay", otherwise as you normally would

# If root or sudo
if [ "$(id -u)" != "0" ]; then
  /usr/bin/echo "Must run as root or sudo!"
  exit 1
fi

# Check for quotes
/usr/bin/echo $@ | /usr/bin/grep -q '"'
if [ "$?" != "0" ]; then
  /usr/bin/echo $@ | /usr/bin/grep -q "'"
  if [ "$?" != "0" ]; then
    /usr/bin/su worker -c "/usr/bin/yay "$@
    exit $?
  else
    /usr/bin/echo "No 'quotes' allowed!"
    exit 1
  fi
else
  /usr/bin/echo "No \"quotes\" allowed!"
  exit 1
fi
