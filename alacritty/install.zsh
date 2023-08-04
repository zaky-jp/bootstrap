#!/usr/bin/env zsh
set -eu

###########
# Initialisation
###########
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
ALACRITTY_CONFIG_HOME="${ALACRITTY_CONFIG_HOME:-$XDG_CONFIG_HOME/alacritty}"
SCRIPT_DIR=$(dirname $(readlink -f $0))

###########
# Create symbolic link
###########

if [[ ! -d "$ALACRITTY_CONFIG_HOME" ]]; then
  mkdir -p "$ALACRITTY_CONFIG_HOME"
fi

if [[ ! -e "/Library/Fonts/SFMonoSquare-Regular.otf" ]]; then
  echo "SFMonoSquare is not yet installed."
  if [[ -d "$(brew --prefix sfmono-square)/share/fonts" ]]; then
    #TODO
    echo
  else
    echo "try \`brew install delphinus/sfmono-square/sfmono-square\`"
  fi
fi

if [[ ! -h "${ALACRITTY_CONFIG_HOME}/alacritty.yml" ]]; then
  ln -s "${SCRIPT_DIR}/configuration.yml" "${ALACRITTY_CONFIG_HOME}/alacritty.yml" 
fi
