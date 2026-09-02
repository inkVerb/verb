#!/bin/bash
#inkVerbDonjon! verb.ink
# Install Go if the box does not already have it (Arch pacman).
# Source from serfs that build Go vapps. Do not put live secrets here.

if ! /usr/bin/command -v go >/dev/null 2>&1; then
  /usr/bin/echo "Go is not installed. Installing..."
  /usr/bin/pacman -Syy --noconfirm go || exit 6
fi
