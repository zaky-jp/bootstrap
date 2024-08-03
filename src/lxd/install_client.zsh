#!/usr/bin/env zsh
set -eu

## importing common functions
## outcome: $PLAYGROUND_DIR/common/zsh-functions/ imported
if [[ ! -d "${PLAYGROUND_DIR}" ]]; then
  echo "\$PLAYGROUND_DIR do not exist. aborting..." 2>&1
  exit 1
fi
source "${PLAYGROUND_DIR}/common/zsh-functions/init"

## installing lxc
## outcome: lxc installed
log_notice "Installing lxc..."
if ! test_command lxc; then
  case "$RUNOS" in
    "macos")
      brew install lxc
      ;;
    "ubuntu")
      apt-get install lxc
      ;;
    *)
      log_fatal "Please install lxc manually. aborting..."
      ;;
  esac
fi
