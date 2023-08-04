#!/usr/bin/env zsh
set -eu

local sdir="${${(%):-%N}:h}" # get relative path to the script dir
local brew_user='homebrew'

# make sure running OS is known
RUNOS="${RUNOS:-}"
if [[ -z "${RUNOS}" ]]; then
  echo "RUNOS not set." 1>&2
  exit 1
fi

function brew() {
  if (dscl . -list /Users | grep -q "${brew_user}"); then
    sudo -i -u "${brew_user}" -- brew "$@"
  else
    brew "$@"
  fi
}

# install byobu
if (( $+commands[byobu] )); then
  echo "byobu already installed."
else
  echo "installing byobu..."
  case $RUNOS in
    ubuntu)
      sudo apt-get update
      sudo apt-get install byobu
      ;;
    macos)
      brew update
      brew install byobu
      ;;
    *)
      echo "${RUNOS} not yet implemented. aborting..." 1>&2
      exit 1
      ;;
  esac
fi

# install config
echo "installing configs..."
if [[ ! -d "${XDG_CONFIG_HOME}/byobu" ]]; then
  mkdir -p "${XDG_CONFIG_HOME}/byobu"
  echo "- created config directory"
fi

if [[ -e "${XDG_CONFIG_HOME}/byobu/status" ]]; then
  # byobu ocasionally writes directly to status and symlink will break
  # thus not attempting symlinking
  cp "${XDG_CONFIG_HOME}/byobu/status" "${XDG_CONFIG_HOME}/byobu/status.bak"
  rm "${XDG_CONFIG_HOME}/byobu/status"
fi
cp "${sdir}/status" "${XDG_CONFIG_HOME}/byobu/status"
echo "- copied status line config"

if [[ ! -h "${XDG_CONFIG_HOME}/byobu/.tmux.conf" ]]; then
  ln -s "${sdir}/tmux.conf" "${XDG_CONFIG_HOME}/byobu/.tmux.conf"
  echo "- copied tmux config"
fi
