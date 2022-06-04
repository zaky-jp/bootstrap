#!/bin/bash
set -eu

# install packages
sudo apt-get install \
  avahi-daemon \
  jq

# activate mDNS
sudo systemctl enable avahi-daemon.service
sudo systemctl start avahi-daemon.service

# setup timezone
sudo timedatectl set-timezone Asia/Tokyo

# install neovim
./../neovim/install.sh

