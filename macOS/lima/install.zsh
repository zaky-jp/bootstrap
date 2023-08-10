#!/usr/bin/env zsh
set -eu
## fail fast
if [[ "${RUNOS}" != "macos" ]]; then
  echo "This script is for macOS only. aborting..." 2>&1
  exit 1
fi

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
# shellcheck source=common/zsh-functions/pkgmgr

## 1. initialization
## outcome: $LIMA_HOME set to $HOME/.lima unless already set
export LIMA_HOME="${LIMA_HOME:-$HOME/.lima}"
log_notice "Installing lima..."

## 1. installing lima and socket_vmnet
## outcome: lima and socket_vmnet installed by appropriate package manager
if ! test_command limactl; then
  brew install lima
fi
if ! brew list socket_vmnet >/dev/null 2>&1; then
  brew install socket_vmnet
fi

## 2. adding configuration files
## outcome: sudoers file added to /private/etc/sudoers.d/lima, default.yaml added to $LIMA_HOME/_config
if [[ ! -d "$(brew --prefix)/opt/socket_vmnet" ]]; then
  # making sure socket_vmnet is available, otherwise lima will not intelligently create appropriate network config
  log_fatal "socket_vmnet not installed. aborting..."
fi

if [[ -e "${LIMA_HOME}/_config/networks.yaml" ]]; then
  log_warn "${LIMA_HOME}/_config/networks.yaml already exists."
  log_info "networks.yaml may need manual adjustments."
fi

limactl sudoers >etc_sudoers.d_lima
sudo install -o root etc_sudoers.d_lima /etc/sudoers.d/lima
rm etc_sudoers.d_lima

safe_symlink "${PLAYGROUND_DIR}/macOS/lima/default.yaml" "${LIMA_HOME}/_config/default.yaml"
safe_symlink "${PLAYGROUND_DIR}/macOS/lima/override.yaml" "${LIMA_HOME}/_config/override.yaml"

## 3. start lima instance
## outcome: lima instance started with "default with some flavour" template
log_notice "Starting lima instance..."
limactl sudoers --check && limactl start --name=default --tty=false 