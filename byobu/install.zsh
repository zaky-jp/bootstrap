#!/usr/bin/env zsh
set -eu

## 0. read lib files
## outcome: zsh-functions under $PLAYGROUND_DIR/common/zsh-functions/ sourced
if [[ ! -v "PLAYGROUND_DIR" ]]; then
  echo "\$PLAYGROUND_DIR not set. aborting..." 2>&1
  exit 1
elif [[ ! -d "${PLAYGROUND_DIR}" ]]; then
  echo "\$PLAYGROUND_DIR do not exist. aborting..." 2>&1
  exit 1
else
  () {
  emulate -L zsh -o extended_glob
  local f
  for f in ${PLAYGROUND_DIR}/common/zsh-functions/*(.); do
    echo "loading ${f}"
    source "${f}"
  done
  }
fi
test_constant

## 1. initialisation
## outcome: $BYOBU_CONFIG set
BYOBU_CONFIG="${BYOBU_CONFIG:-${XDG_CONFIG_HOME}/byobu}"
log_notice "Installing byobu..."

## 2. installing byobu
## outcome: byobu installed by appropriate package manager
local pkg="byobu"
if ! test_command "${pkg}"; then
  case "$RUNOS" in
    "macos")
      brew install "${pkg}";;
    "ubuntu")
      apt install "${pkg}";;
    *)
      log_fatal "Please install ${pkg} manually. aborting...";;
  esac
fi

## 3. copying configuration files
## outcome: config files copied to ${BYOBU_CONFIG}
log_info "backing up current config"
backup "${BYOBU_CONFIG}/status"
backup "${BYOBU_CONFIG}/.tmux.conf"

log_info "copying PLAYGROUND config"
mkdir -p "${BYOBU_CONFIG}"
cp "${PLAYGROUND_DIR}/byobu/status" "${BYOBU_CONFIG}/status"
safe_symlink "${PLAYGROUND_DIR}/byobu/tmux.conf" "${BYOBU_CONFIG}/.tmux.conf"
