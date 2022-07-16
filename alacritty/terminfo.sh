#!/usr/bin/env bash
set -eu

# config
TERMINFO_URL=https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info

# download terminfo
TERMINFO_PATH="$(mktemp -d)/alacritty.info"
curl -sfLo "${TERMINFO_PATH}" "${TERMINFO_URL}"

# install terminfo
if [[ -r "${TERMINFO_PATH}" ]]; then
  tic -xe alacritty,alacritty-direct "${TERMINFO_PATH}"
else
  echo "TERMINFO file not readable by user" 1>&2
  exit 2
fi
