#!/usr/bin/env zsh
set -eu

# make sure running OS is known, otherwise fail fast
RUNOS="${RUNOS:-}"
if [[ -z "${RUNOS}" ]]; then
  echo "RUNOS not set." 1>&2
  exit 1
fi

# config
local apt="${apt:-sudo apt-get}"
local brew="${brew:-sudo -l -u _brew -- brew}"
JETPACK_URL=https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}


# check for nvim installation
printf "Checking if nvim is installed... "
if (( $+commands[nvim] )); then
  printf "[installed]\n"
else
  printf "not found.\n"
  echo "Begin installation..."
  # install neovim
  case "${RUNOS}" in
    'ubuntu')
      $apt update
      $apt install neovim
      ;;
    'darwin')
      brew="$S -l -u _brew -- brew"
      $brew update
      $brew install neovim
      ;;
    *)
      echo "Running on unintended OS." 1>&2
      exit 1
      ;;
  esac
fi

# make sure nvim is in the path
if ! (( $+commands[nvim] )); then
  echo "nvim not found on path" 1>&2
  exit 1
fi

# configure update-alternatives if exists
if (( $+commands[update-alternatives] )); then
  echo "Configuring update-alternatives..."
  local lib_path="/usr/libexec/neovim" # hardcoded

  local tool list=(editor vi vim)
  for tool in "${list[@]}"; do
    echo "\t$tool"
    sudo update-alternatives --set "${tool}" "$commands[nvim]"
  done

  if [[ -d ${lib_path} ]]; then
    list=(ex view rview rvim vimdiff)
    for tool in "${list[@]}"; do
      echo "\t$tool"
      sudo update-alternatives --set "${tool}" "${lib_path}/${tool}"
    done
  else
    echo "${lib_path} not found on system. skipping update-alternatives..." 1>&2
  fi
fi

# get XDG dirs ready
if ! [[ -d ${XDG_DATA_HOME} && -d ${XDG_CONFIG_HOME} ]]; then
  echo "Getting XDG dirs ready..."
  mkdir -p "${XDG_DATA_HOME}"
  mkdir -p "${XDG_CONFIG_HOME}"
fi

# install package manager
local JETPACK_PATH="${XDG_DATA_HOME}/nvim/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim"
if [[ -e ${JETPACK_PATH} ]]; then
  echo "Jetpack already installed"
else
  echo "Installing jetpack..."
  curl -sfLo "${JETPACK_PATH}" --create-dirs "${JETPACK_URL}"
  if ! [[ -e "${JETPACK_PATH}" ]]; then
    echo "Jetpack could not be placed under XDG_DATA_HOME" 1>&2
    exit 1
  fi
fi

# symlink init.vim
if ! [[ -e "${XDG_CONFIG_HOME}/nvim/init.vim" ]]; then
  echo "Symlinking init.vim to XDG_CONFIG_HOME"
  ln -s "${SCRIPT_DIR}/init.vim" "${XDG_CONFIG_HOME}/nvim/init.vim"
fi
