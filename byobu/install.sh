#!/usr/bin/env zsh
set -eu

# config
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
SCRIPT_DIR="$(dirname "$(realpath -s "$0")")"

if (( $+commands[lsb_release] )); then # if linux flavour
  case "$(lsb_release --id --short)" in
    Ubuntu)
      sudo apt-get update && \
      sudo apt-get install byobu
      ;;
  esac
elif (( $+commands[brew] )) && [[ "$(sw_vers -productName)" == 'macOS' ]]; then
  if ! (brew list --formulae -1 | grep -q 'byobu'); then
    brew install byobu
  fi
fi

# make sure to prepare config directory
mkdir -p "${XDG_CONFIG_HOME}/byobu"

# byobu ocasionally writes directly to status and symlink will break
# thus not attempting symlinking
cp ./status "${XDG_CONFIG_HOME}/byobu/status"

ln -s "${SCRIPT_DIR}/tmux.conf" "${XDG_CONFIG_HOME}/byobu/.tmux.conf"
