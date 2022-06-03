#!/bin/bash

set -eu

# config
TERMINFO_URL=https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info

# install terminfo
curl -sfL ${TERMINFO_URL} | \
  sudo tic -xe alacritty,alacritty-direct -
