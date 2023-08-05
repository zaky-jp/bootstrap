#!/bin/bash
set -eu
INDENT_CHARS="==> "

## 1. check terminfo status
## outcome: terminate if terminfo is available
if infocmp alacritty >/dev/null 2>&1; then
  echo "${INDENT_CHARS}terminfo already installed"
  exit
else
  echo "${INDENT_CHARS}Installing alacritty terminfo..."
fi

## 2. install terminfo filne
## outcome: alacritty terminfo saved to /usr/share/terminfo
tic -xe alacritty,alacritty-direct "${PLAYGROUND_DIR}/alacritty/upstream/extra/alacritty.info"