#!/bin/bash

set -eu

# config
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
SCRIPT_DIR=$(dirname $(realpath -s $0))

if [[ $(lsb_release --id --short) = 'Ubuntu' ]]; then
  sudo apt-get update && \
    sudo apt-get install byobu
fi

# make sure to prepare config directory
mkdir -p ${XDG_CONFIG_HOME}/byobu

# byobu ocasionally writes directly to status and symlink will break
# thus not attempting symlinking
cp ./status ${XDG_CONFIG_HOME}/byobu/status

ln -s ${SCRIPT_DIR}/tmux.conf ${XDG_CONFIG_HOME}/byobu/.tmux.conf

