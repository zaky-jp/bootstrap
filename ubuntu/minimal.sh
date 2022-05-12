#!/bin/bash

set -eu

# configs
GITHUB_REPO=zaky-jp/playground

# apt configs
local GITHUB_REPO_RAW=https://raw.githubusercontent.com/${GITHUB_REPO}/main
curl -sfL ${GITHUB_REPO_RAW}/ubuntu/etc/apt/mirrors.txt | \
  sudo tee /etc/apt/mirrors.txt >/dev/null
curl -sfL ${GITHUB_REPO_RAW}/ubuntu/etc/apt/sources.list | \
  sudo tee /etc/apt/sources.list >/dev/null
curl -sfL ${GITHUB_REPO_RAW}/ubuntu/etc/apt/apt.conf | \
  sudo tee /etc/apt/apt.conf >/dev/null

# use latest packages
sudo apt update && sudo apt upgrade
sudo snap refresh

# install packages
sudo apt install \
  doas \
  git

# setup doas
echo "permit persist :adm" | sudo tee /etc/doas.conf > /dev/null
doas -C /etc/doas.conf && \
  echo "alias sudo=doas" >> ~/.bashrc && \
  source ~/.bashrc

# clone playground
git clone https://github.com/${GITHUB_REPO}.git
