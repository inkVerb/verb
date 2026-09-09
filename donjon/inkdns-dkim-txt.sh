#!/bin/bash
#inkVerbDonjon! verb.ink
# BIND TXT helpers. RFC 1035 character-strings are max 255 octets.
# Sourced by inkdnsaddinkdkim / showinkdkim / updateinkdnsdkim.

# inkdns_txt_rdata RAW
# prints: "short"   OR   ( "chunk1" "chunk2" )
inkdns_txt_rdata() {
  local s="$1"
  local chunk
  if [ ${#s} -le 255 ]; then
    /usr/bin/printf '"%s"' "$s"
    return 0
  fi
  /usr/bin/printf '( '
  while [ ${#s} -gt 255 ]; do
    chunk="${s:0:255}"
    s="${s:255}"
    /usr/bin/printf '"%s" ' "$chunk"
  done
  /usr/bin/printf '"%s" )' "$s"
}

# inkdns_quoted_concat FILE
# concatenates every "..." piece from an OpenDKIM / Maddy / zone file
inkdns_quoted_concat() {
  [ -f "$1" ] || return 1
  /usr/bin/grep -oE '"[^"]*"' "$1" 2>/dev/null | /usr/bin/sed 's/^"//;s/"$//' | /usr/bin/tr -d '\n'
}

# inkdns_dkim_value_from_file FILE
# raw DKIM TXT (v=DKIM1; ...) from OpenDKIM txt or Maddy .dns
inkdns_dkim_value_from_file() {
  local f="$1"
  local val p
  val="$(inkdns_quoted_concat "$f")"
  if [ -n "${val}" ]; then
    /usr/bin/printf '%s' "${val}"
    return 0
  fi
  p="$(/usr/bin/grep -oE 'p=[A-Za-z0-9+/]+=*' "$f" 2>/dev/null | /usr/bin/head -1 | /usr/bin/sed 's/^p=//')"
  if [ -n "${p}" ]; then
    /usr/bin/printf 'v=DKIM1; k=rsa; p=%s' "${p}"
    return 0
  fi
  return 1
}
