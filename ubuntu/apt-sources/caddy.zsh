#!/usr/bin/env zsh
set -eu

source "${PLAYGROUND_DIR}/ubuntu/apt-sources/common"

install_key_from_url\
  'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
  'caddy.asc'

create_source_list\
  'caddy.list'\
  'deb https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main'