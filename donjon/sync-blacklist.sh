#!/bin/bash
# inkVerb donjon asset, verb.ink
## This leans spam and blacklists maddy messages in the Blacklist folder
### Without this, the Blacklist folder won't delete, blacklist, or learn spam from the messages placed there
## This is meant to run regularly by cron

Storage="/srv/email/maddy/messages"
BlacklistMap="/etc/rspamd/maps/blacklist.map"

# Ensure the Blacklist foler for all users
for user_dir in "${Storage}"/*; do
  if [ -d "$user_dir" ] && [ ! -d "$user_dir/.Blacklist" ]; then
    /usr/bin/echo "Creating Blacklist folder for $(/usr/bin/basename "$user_dir")"
    /usr/bin/mkdir -p "$user_dir"/.Blacklist/{cur,new,tmp}
    /usr/bin/chown -R maddy:maddy "$user_dir"/.Blacklist
  fi
done

# Find all new messages in any .Blacklist folder across all users
## Then extract From address, append to map, remove any dups
/usr/bin/find "${Storage}" -type d -path "*/.Blacklist/new" -exec grep -hR "^From: " {} + | \
/usr/bin/grep -oE "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" | \
/usr/bin/sort -u >> "$BlacklistMap"

# Resort the map file
/usr/bin/sort -u "$BlacklistMap" -o "$BlacklistMap"

# Learn spam in Rspamd since we're here (optional, but we want this)
/usr/bin/find "${Storage}" -type d -path "*/.Blacklist/new" -exec rspamc learn_spam {} +

# Move processed mail to 'cur' so we don't process it twice
## In maddy/Roundcube, Trash is usually '.Trash'
/usr/bin/find "${Storage}" -type d -path "*/.Blacklist/new" -mindepth 1 -exec mv {} "${Storage}"/{}/../../.Trash/cur/ \;

# Reload rspamd
/usr/bin/systemctl reload rspamd
