#!/usr/bin/env zsh
set -eu

source "${PLAYGROUND_DIR}/ubuntu/apt-sources/common"

install_key_from_url\
  'https://packages.cloud.google.com/apt/doc/apt-key.gpg' \
  'google-cloud-sdk.asc'

create_source_list\
  'google-cloud-sdk.list'\
  'deb http://packages.cloud.google.com/apt cloud-sdk main'
