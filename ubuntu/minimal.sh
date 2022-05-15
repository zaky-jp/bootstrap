#!/bin/bash

set -eu

# configs
GITHUB_REPO=zaky-jp/playground

# apt configs
GITHUB_REPO_RAW=https://raw.githubusercontent.com/${GITHUB_REPO}/main
echo "Fetching apt configs:"
curl -sfL ${GITHUB_REPO_RAW}/ubuntu/etc/apt/mirrors.txt | \
  sudo tee /etc/apt/mirrors.txt >/dev/null
curl -sfL ${GITHUB_REPO_RAW}/ubuntu/etc/apt/sources.list | \
  sudo tee /etc/apt/sources.list >/dev/null
curl -sfL ${GITHUB_REPO_RAW}/ubuntu/etc/apt/apt.conf | \
  sudo tee /etc/apt/apt.conf >/dev/null

DEBIAN_FRONTEND=noninteractive

# use latest packages
echo
echo "Updating to latest packages:"
sudo apt update && sudo apt upgrade
sudo snap refresh

# install packages
echo
echo "Install neccessary tools:"
# TODO implement flag for no-recommends
sudo apt install --no-install-recommends \
  doas \
  git

# setup doas
## TODO: make this work in non-user environment
echo
echo "permit persist :adm" | sudo tee /etc/doas.conf > /dev/null
doas -C /etc/doas.conf && \
  echo "alias sudo=doas" >> ~/.bashrc

# clone playground
echo
echo "Cloning playground directory:"
git clone https://github.com/${GITHUB_REPO}.git
