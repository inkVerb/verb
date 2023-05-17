#!/bin/bash
# inkNet cron, verb.ink
/usr/bin/find /srv/www/verb/${vTLD}.serve/${sDIR}/* -type d -mmin +30 -exec rm -rf {} \;
