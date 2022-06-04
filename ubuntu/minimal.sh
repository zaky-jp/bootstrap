#!/bin/bash
set -eu

# config
SETUP_TYPE=${SETUP_TYPE:-'server'}
GITHUB_REPO=${GITHUB_REPO:-'zaky-jp/playground'}
DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-'readline'}
export DEBIAN_FRONTEND

# install ca-certificates
echo "Updating package list..."
sudo --preserve-env=DEBIAN_FRONTEND apt-get \
  --option "Acquire::https::Verify-Peer=false" update
echo
echo "Installing ca-certificates..."
sudo --preserve-env=DEBIAN_FRONTEND apt-get \
  --option "Acquire::https::Verify-Peer=false" install \
  --no-install-recommends ca-certificates

# set mirrors
_dir=$(mktemp --directory)

# for 
function _curl() {
  echo "Fetching $1"
  curl \
    --silent \
    --show-error \
    --location \
    --output-dir ${_dir} \
    --remote-name \
    "$@"
}

GITHUB_REPO_RAW=https://raw.githubusercontent.com/${GITHUB_REPO}/main/ubuntu/etc/apt
echo
echo "Fetching apt configs from '${GITHUB_REPO}':"

# assuming jammy setup
_curl ${GITHUB_REPO_RAW}/sources.list &&
  sudo cp ${_dir}/sources.list /etc/apt/sources.list

_curl ${GITHUB_REPO_RAW}/mirrors.${SETUP_TYPE}.txt &&
  sudo cp ${_dir}/mirrors.${SETUP_TYPE}.txt /etc/apt/mirrors.txt

_curl ${GITHUB_REPO_RAW}/apt.${SETUP_TYPE}.conf && \
  sudo cp ${_dir}/apt.${SETUP_TYPE}.conf /etc/apt/apt.conf

# even running minimal-ubuntu container we still want to cache apt packages
if [[ -r /etc/apt/apt.conf.d/docker-clean ]]; then
  sudo rm /etc/apt/apt.conf.d/docker-clean
fi

# upgrading to latest package
echo
echo "Upgrading apt packages..."
sudo --preserve-env=DEBIAN_FRONTEND apt-get update
sudo --preserve-env=DEBIAN_FRONTEND apt-get upgrade
echo
echo "Upgrading snap installs..."
sudo snap refresh
