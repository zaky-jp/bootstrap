#!/bin/bash

set -eu

# defaults
FROM='server'
GITHUB_REPO='zaky-jp/playground'

# parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --type)
      TYPE=$2
      shift
      shift
      ;;
    --github-repo)
      GITHUB_REPO=$2
      shift
      shift
      ;;
  esac
done

# install ca-certificates
echo
echo "Updating package list..."
sudo apt-get --option "Acquire::https::Verify-Peer=false" update
echo "Installing ca-certificates..."
sudo apt-get --option "Acquire::https::Verify-Peer=false" install --no-install-recommends ca-certificates

# set mirrors
GITHUB_REPO_RAW=https://raw.githubusercontent.com/${GITHUB_REPO}/main
echo "Fetching apt configs from '${GITHUB_REPO}':"
# assuming jammy setup
curl -sfL ${GITHUB_REPO_RAW}/ubuntu/etc/apt/sources.list | \
  sudo tee /etc/apt/sources.list >/dev/null
curl -sfL ${GITHUB_REPO_RAW}/ubuntu/etc/apt/mirrors.${TYPE}.txt | \
  sudo tee /etc/apt/mirrors.txt >/dev/null
curl -sfL ${GITHUB_REPO_RAW}/ubuntu/etc/apt/apt.${TYPE}.conf | \
  sudo tee /etc/apt/apt.conf >/dev/null

# even running minimal-ubuntu container we still want to cache apt packages
if [[ -r /etc/apt/apt.conf.d/docker-clean ]]; then
  sudo rm /etc/apt/apt.conf.d/docker-clean
fi

# upgrading to latest package
echo
echo "Upgrading apt packages..."
sudo apt-get update && sudo apt-get upgrade
echo "Upgrading snap installs..."
sudo snap refresh
