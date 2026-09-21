#!/usr/bin/bash
# inkVerb donjon: space + dest for backup* .vbak files
# Sourced by backup, backupnextcloud, backupvmail, backuprestore
# tar -h (vtxzin) already stores inkDrive bind mounts and /mnt/{h|s}dd symlinks as real dirs.

# Apparent tree size in KB, following bind mounts and symlink dirs (du -L).
vbak_tree_kb() {
  local p="${1}"
  if [ ! -e "${p}" ]; then
    /usr/bin/echo 0
    return 0
  fi
  /usr/bin/du -skL "${p}" 2>/dev/null | /usr/bin/awk '{print $1}'
}

# Need: 110% of tree + 100MB leftover on the destination.
vbak_need_kb() {
  local kb="${1:-0}"
  [ -z "${kb}" ] && kb=0
  /usr/bin/echo $(( kb + kb / 10 + 102400 ))
}

# Free KB on the filesystem that contains path (dir may not exist yet).
vbak_avail_kb() {
  local p="${1}"
  local probe="${p}"
  while [ ! -d "${probe}" ] && [ "${probe}" != "/" ]; do
    probe=$(/usr/bin/dirname "${probe}")
  done
  /usr/bin/df -kP "${probe}" 2>/dev/null | /usr/bin/awk 'NR==2 {print $4}'
}

# inkDrive mountpoints only (real disks, not empty /mnt dirs).
vbak_ink_mnts() {
  local d name f
  for d in /mnt/hdd /mnt/ssd; do
    if /usr/bin/mountpoint -q "${d}" 2>/dev/null; then
      /usr/bin/echo "${d}"
    fi
  done
  if [ -d /opt/verb/conf/inkdrive ]; then
    for f in /opt/verb/conf/inkdrive/hdd.* /opt/verb/conf/inkdrive/ssd.*; do
      [ -f "${f}" ] || continue
      name=$(/usr/bin/basename "${f}")
      name="${name#hdd.}"
      name="${name#ssd.}"
      [ -z "${name}" ] && continue
      d="/mnt/${name}"
      if /usr/bin/mountpoint -q "${d}" 2>/dev/null; then
        /usr/bin/echo "${d}"
      fi
    done
  fi
}

# Echo dest directory (…/vip) with enough free space. Prefer attached disk with most free. Fail 4 if none.
# Usage: dest=$(vbak_dest NEED_KB) || return 4
vbak_dest() {
  local need="${1}"
  local best="" best_avail=0 d avail vip="/srv/www/vip"
  local seen="|"
  while read -r d; do
    [ -z "${d}" ] && continue
    case "${seen}" in
      *"|${d}|"*) continue ;;
    esac
    seen="${seen}${d}|"
    avail=$(vbak_avail_kb "${d}")
    [ -z "${avail}" ] && continue
    if [ "${avail}" -ge "${need}" ] && [ "${avail}" -gt "${best_avail}" ]; then
      best="${d}/vip"
      best_avail="${avail}"
    fi
  done < <(vbak_ink_mnts)
  if [ -n "${best}" ]; then
    /usr/bin/mkdir -p "${best}"
    /usr/bin/echo "${best}"
    return 0
  fi
  /usr/bin/mkdir -p "${vip}"
  avail=$(vbak_avail_kb "${vip}")
  if [ -n "${avail}" ] && [ "${avail}" -ge "${need}" ]; then
    /usr/bin/echo "${vip}"
    return 0
  fi
  local needh avh
  needh=$(/usr/bin/numfmt --to=iec-i --suffix=B $((need * 1024)) 2>/dev/null || /usr/bin/echo "${need}K")
  avh=$(/usr/bin/numfmt --to=iec-i --suffix=B $((${avail:-0} * 1024)) 2>/dev/null || /usr/bin/echo "${avail:-0}K")
  /usr/bin/echo "Not enough disk for this backup. Need about ${needh} free (tree plus ~10% and 100M leftover). Best available: ${avh}." >&2
  return 4
}

# Point /srv/www/vip/NAME at the real .vbak (file may already live there).
vbak_linkvip() {
  local real="${1}"
  local base
  base=$(/usr/bin/basename "${real}")
  /usr/bin/mkdir -p /srv/www/vip
  if [ "$(/usr/bin/readlink -f "${real}")" = "$(/usr/bin/readlink -f "/srv/www/vip/${base}" 2>/dev/null)" ]; then
    return 0
  fi
  /bin/ln -sfn "${real}" "/srv/www/vip/${base}"
}
