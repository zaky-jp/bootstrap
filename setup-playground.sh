#!/bin/bash
set -eu

# config
PLAYGROUND_REPO=${PLAYGROUND_REPO:-'zaky-jp/playground'}
TARGET_DIR=$HOME/playground
DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-'readline'}
export DEBIAN_FRONTEND

if ! (which git 1>/dev/null 2>&1); then
  echo "git not present in your system"
  echo "trying to install..."
  if (which apt 1>/dev/null 2>&1); then
    sudo --preserve-env=DEBIAN_FRONTEND apt-get update
    sudo --preserve-env=DEBIAN_FRONTEND apt-get install git
  elif (which brew 1>/dev/null 2>&1); then
    brew update
    brew install git
  fi
fi

if [[ -d ${TARGET_DIR} ]]; then
  echo "${TARGET_DIR} already exists" 2>&1
else
  git clone https://github.com/${PLAYGROUND_REPO}.git ${TARGET_DIR}
fi
