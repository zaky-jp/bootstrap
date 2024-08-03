#!/usr/bin/env zsh
set -eu

source "${PLAYGROUND_DIR}/ubuntu/apt-sources/common"

install_key_from_url\
  'https://cli.github.com/packages/githubcli-archive-keyring.gpg' \
  'githubcli-archive-keyring.gpg'

create_source_list\
  'github-cli.list'\
  'deb https://cli.github.com/packages stable main'
