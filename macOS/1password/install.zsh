#!/usr/bin/env zsh
set -eu

RUNOS="${RUNOS:-}"
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-$HOME/.run}"

# echo
function notice() {
  # echo green
  print -P "%F{green}$*%f"
}

function warn() {
  # echo red
  print -P "%F{red}$*%f" 1>&2
}

function info() {
  # echo with indent
  print "==> $*"
}

notice "Installing 1password GUI..."
case $RUNOS in
  macos*)
    if [[ -d "/Applications/1Password.app" ]]; then
      info "1Password already installed."
      info "skipping installation"
    else
      info "installing 1Password..."
      brew install --cask 1password
    fi
  ;;
  *)
    warn "${RUNOS} not yet implemented. aborting..."
    exit 1
  ;;
esac

notice "Setting up 1passowrd SSH agent"
if [[ -e "${XDG_RUNTIME_DIR}/1password/agent.sock" ]]; then
  info "SSH agent already present."
  info "skipping setup"
else
  case $RUNOS in
    macos)
      info "Please enable 'use ssh agent' option"
      open "/Applications/1Password.app"
      read -k 1 -n "?Please enter any key after enabling the option"
      print "\n"
      info "creating 1password directory under XDG_RUNTIME_DIR"
      mkdir -p "${XDG_RUNTIME_DIR}/1password"
      info "symlinking 1password agent"
      ln -s "${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" "${XDG_RUNTIME_DIR}/1password/agent.sock"
      ;;
    *)
      warn "${RUNOS} not yet implemented. aborting..."
      exit 1
  esac
  export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/1password/agent.sock"
fi

