#!/usr/bin/env bash
set -eu

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
SCRIPT_DIR="$(dirname "$(realpath -s "$0")")"

# make sure running OS is known
RUNOS="${RUNOS:-}"
if [[ -z "${RUNOS}" ]]; then
  echo "RUNOS not set." 1>&2
  exit 1
fi

# make sure dir exists
if [[ ! -d "${ZDOTDIR}" ]]; then
  echo "Creating zsh config under \$XDG_CONFIG_HOME"
  mkdir -p "${ZDOTDIR}"
fi

# check if zsh is already installed
if ! (which zsh 1>/dev/null 2>&1); then
  case "${RUNOS}" in
    'ubuntu')
      sudo apt-get install zsh
      ;;
    '*')
      echo "Install script is not aware of installation process for ${RUNOS}"
      ;;
  esac
else
  echo "zsh already installed."
fi

# set proper ZDOTDIR
case "$RUNOS" in
  'ubuntu') _zshenv_path="/etc/zsh/zshenv" ;;
  *) _zshenv_path="/etc/zshenv"
esac
if ! (grep -q 'ZDOTDIR' "${_zshenv_path}" 2>/dev/null); then
  echo "Creating ${_zshenv_path}..."
  # do not want to hardcode $HOME/.config but not hardcoding requires to have ~/.zshenv for all users
  echo 'ZDOTDIR=$HOME/.config/zsh' | sudo tee -a "${_zshenv_path}"
else
  echo "ZDOTDIR already present at ${_zshenv_path}"
fi

# symlink init files
function _symlink() {
  _src="$1"
  _dst="$2"
  if [[ -e "${_src}" ]]; then
    echo "${_src} already exists."
  else
    mkdir -p "$(dirname $_src)"
    echo "Symlinking ${_src}"
    ln -s "${_dst}" "${_src}"
  fi
}

_symlink "${ZDOTDIR}/.zshenv" "${SCRIPT_DIR}/env.zsh"
_symlink "${ZDOTDIR}/.zprofile" "${SCRIPT_DIR}/profile.zsh"
_symlink "${ZDOTDIR}/.zshrc" "${SCRIPT_DIR}/rc.zsh"
_symlink "${ZDOTDIR}/.p10k.zsh" "${SCRIPT_DIR}/p10k.zsh"
_symlink "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/functions" "${SCRIPT_DIR}/functions"
