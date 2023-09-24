#!/usr/bin/env zsh
set -eu

## 0. source common functions
## outcome: $PLAYGROUND_DIR/common/zsh-functions/ sourced
if [[ ! -d "${PLAYGROUND_DIR}" ]]; then
  echo "\$PLAYGROUND_DIR do not exist. aborting..." 2>&1
  exit 1
fi
source "${PLAYGROUND_DIR}/common/zsh-functions/init"

## 1. initialisation
## outcome: VOLTA_HOME configured
export VOLTA_HOME="${XDG_DATA_HOME}/volta/"

## 1. install volta from helper sh
log_notice "Installing volta..."
if ! test_command volta; then
  safe_mkdir "$VOLTA_HOME"
  export PATH="${VOLTA_HOME}/bin":"$PATH"
  curl -fsSL https://get.volta.sh | bash -x -s -- --skip-setup
fi

## 2. install latest node and npm
log_notice "Installing node..."
if volta list node --format plain | grep -q 'runtime'; then
  log_info 'node already installed.'
else
  volta install node
fi
