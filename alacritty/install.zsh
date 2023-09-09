#!/usr/bin/env zsh
set -eu

## 0. source common functions
## outcome: $PLAYGROUND_DIR/common/zsh-functions/ sourced
if [[ ! -d "${PLAYGROUND_DIR}" ]]; then
  echo "\$PLAYGROUND_DIR do not exist. aborting..." 2>&1
  exit 1
fi
source "${PLAYGROUND_DIR}/common/zsh-functions/init"

## 1. initialisation
## outcome: $ALACRITTY_CONFIG set
ALACRITTY_CONFIG="${ALACRITTY_CONFIG:-${XDG_CONFIG_HOME}/alacritty}"
log_notice "Installing alacritty..."

## 2. installing alacritty
## outcome: alacritty installed by appropriate package manager
local pkg="alacritty"
if ! test_command "${pkg}"; then
  case "$RUNOS" in
    "macos")
      brew install "${pkg}";;
    *)
      log_fatal "Please install ${pkg} manually. aborting...";;
  esac
fi

## 3. [if macos] installing SF Mono Square font
## outcome: SF Mono Square font files copied to /Library/Fonts/
if [[ $RUNOS="macos" && ! -e "/Library/Fonts/SFMonoSquare-Regular.otf" ]]; then
  log_notice "SFMonoSquare is not yet installed."
  if [[ -d "$(brew --prefix sfmono-square)/share/fonts" ]]; then
    log_info "SFMonoSquare is already generated."
  else
    brew install delphinus/sfmono-square/sfmono-square
  fi
  log_info "moving fonts to /Library/Fonts"
  () {
    emulate -L zsh -o extended_glob
    sudo cp -n "$(brew --prefix sfmono-square)"/share/fonts/*.otf /Library/Fonts
  }
fi

## 4. symlinking configuration file
## outcome: configuration file symlinked to $ALACRITTY_CONFIG
safe_symlink "${PLAYGROUND_DIR}/alacritty/configuration.yml" "${ALACRITTY_CONFIG}/alacritty.yml"

## 5. installing terminfo file
## outcome: terminfo file saved under /usr/share/terminfo or $TERMINFO
# this is required as screen/tmux refer terminfo folder, and do not refer to internal terminfo under /Application folder (at least for macos)
"${PLAYGROUND_DIR}/alacritty/terminfo.sh"

# vim: se filetype=zsh:
