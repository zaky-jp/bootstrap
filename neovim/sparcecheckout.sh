#!/bin/bash
set -eux

# initialize jetpack
git submodule update --init --remote "${PLAYGROUND_DIR}/neovim/jetpack"

# adopted from https://leico.github.io/TechnicalNote/Git/sparse-checkout-submodule
git -C "${PLAYGROUND_DIR}/neovim/jetpack" config core.sparsecheckout true

cat <<EOS | tee "${PLAYGROUND_DIR}/.git/modules/neovim/jetpack/info/sparse-checkout" >/dev/null
plugin/jetpack.vim
EOS

git -C "${PLAYGROUND_DIR}/neovim/jetpack" read-tree -mu HEAD
