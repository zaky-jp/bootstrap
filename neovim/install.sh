#!/usr/bin/env bash
set -eu

# config
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
JETPACK_URL=https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim
SCRIPT_DIR="$(dirname "$(realpath -s "$0")")"

# linux-flavour
if (which -s lsb_release); then
  # ubuntu
  if [[ $(lsb_release --id --short) == "Ubuntu" ]]; then
    # install neovim
    sudo apt-get update
    sudo apt-get install neovim

  # update-alternatives
  vim_alts=(editor vi vim)
  tool_alts=(ex view rview rvim vimdiff)
  _nvim=$(which nvim 2>/dev/null)
  _tool_dir=/usr/libexec/neovim #TODO remove hard-coding

  for alt in "${vim_alts[@]}"; do
    sudo update-alternatives --set "${alt}" "${_nvim}"
  done

  for alt in "${tool_alts[@]}"; do
    sudo update-alternatives --set "${alt}" "${_tool_dir}/${alt}"
  done
  fi
fi

# check if nvim is in the path
if ! (which -s nvim); then
  echo "somehow neovim is not successfully installed" 1>&2
  exit 1
fi

# get XDG dirs ready
mkdir -p "${XDG_DATA_HOME}"
mkdir -p "${XDG_CONFIG_HOME}"

# install package manager
JETPACK_PATH="${XDG_DATA_HOME}/nvim/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim"
curl -sfLo "${JETPACK_PATH}" --create-dirs "${JETPACK_URL}"
if ! [[ -e "${JETPACK_PATH}" ]]; then
  echo "jetpack could not be placed under XDG_DATA_HOME" 1>&2
  exit 1
fi

# symlink init.vim
if ! [[ -e "${XDG_CONFIG_HOME}/nvim/init.vim" ]]; then
  ln -s "${SCRIPT_DIR}/init.vim" "${XDG_CONFIG_HOME}/nvim/init.vim"
fi
