#!/usr/bin/env zsh
set -eu

local sdir="${${(%):-%N}:h}" # get relative path to the script dir

if [[ -e /etc/buildkit/buildkitd.toml ]]; then
  sudo mkdir -p /etc/buildkit
  sudo cp "${sdir}/buildkitd.toml" /etc/buildkit/buildkitd.toml
fi
