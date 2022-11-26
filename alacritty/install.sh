#!/usr/bin/env bash
set -eu

###########
# Initialisation
###########
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
ALACRITTY_CONFIG_HOME="${ALACRITTY_CONFIG_HOME:-$XDG_CONFIG_HOME/alacritty}"
SCRIPT_DIR=$(dirname $(realpath -s $0))

###########
# Create symbolic link
###########

if [[ ! -d "$ALACRITTY_CONFIG_HOME" ]]; then
	mkdir -p "$ALACRITTY_CONFIG_HOME"
fi

ln -s "${SCRIPT_DIR}/configuration.yml" "${ALACRITTY_CONFIG_HOME}/alacritty.yml" 
