#!/usr/bin/env zsh
set -eu

## 0. reading lib files
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

## 1. install keyring files
## outcome: github-cli keyring ans source.list added
# load helper function
source "${PLAYGROUND_DIR}/ubuntu/apt-sources/common"

log_notice "adding github source repo to apt system..."
log_info "downloading gpg key"
install_key_from_url\
  'https://cli.github.com/packages/githubcli-archive-keyring.gpg' \
  'githubcli-archive-keyring.gpg'

log_info "creating source.list"
create_source_list\
  'github-cli.list'\
  'deb https://cli.github.com/packages stable main'
