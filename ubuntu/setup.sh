#!/bin/bash

set -eu

# install packages
sudo apt install \
  neovim \
  avahi-daemon \
  jq

# activate mDNS
sudo systemctl enable avahi-daemon.service
sudo systemctl start avahi-daemon.service

# setup timezone
sudo timedatectl set-timezone Asia/Tokyo

# set default editor
nvim_path=$(which nvim 2>/dev/null)

vim_alts=(\
  editor \
  vi \
  vim \
)

for alt in ${vim_alts[@]}; do
  sudo update-alternatives --set ${alt} ${nvim_path}
done

tool_dir=/usr/libexec/neovim #TODO remove hard-coding

tool_alts=(\
  ex \
  view \
  rview \
  rvim \
  vimdiff \
)

for alt in ${tool_alts[@]}; do
  sudo update-alternatives --set ${alt} ${tool_dir}/${alt}
done

