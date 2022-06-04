#!/bin/bash
set -eu

# config
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
JETPACK_URL=https://raw.githubusercontent.com/tani/vim-jetpack/master/autoload/jetpack.vim
SCRIPT_DIR=$(dirname $(realpath -s $0))

# ubuntu
if [[ $(lsb_release --id --short) = "Ubuntu" ]]; then
  # install neovim
  sudo apt-get update
  sudo apt-get install neovim

  # update-alternatives
  vim_alts=(editor vi vim)
  tool_alts=(ex view rview rvim vimdiff)
  _nvim=$(which nvim 2>/dev/null)
  _tool_dir=/usr/libexec/neovim #TODO remove hard-coding

  for alt in ${vim_alts[@]}; do
    sudo update-alternatives --set ${alt} ${_nvim}
  done

  for alt in ${tool_alts[@]}; do
    sudo update-alternatives --set ${alt} ${_tool_dir}/${alt}
  done
fi

# check if nvim is in the path
if ! (which nvim 1>/dev/null 2>&1); then
  echo "somehow neovim is not successfully installed" 1>&2
  exit 1
fi

# get XDG dirs ready
mkdir -p ${XDG_DATA_HOME}
mkdir -p ${XDG_CONFIG_HOME}

# install package manager
curl -sfL -o ${XDG_CONFIG_HOME}/nvim/autoload/jetpack.vim --create-dirs ${JETPACK_URL} 

# symlink init.vim
ln -s ${SCRIPT_DIR}/init.vim ${XDG_CONFIG_HOME}/nvim/init.vim

# initial package sync
nvim -c JetpackSync
