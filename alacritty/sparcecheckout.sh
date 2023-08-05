#!/bin/bash
# adopted from https://leico.github.io/TechnicalNote/Git/sparse-checkout-submodule
git -C "${PLAYGROUND_DIR}/alacritty/upstream" config core.sparsecheckout true
cat <<EOS | tee "${PLAYGROUND_DIR}/.git/modules/alacritty/upstream/info/sparse-checkout" >/dev/null
extra/alacritty.info
EOS
git -C "${PLAYGROUND_DIR}/alacritty/upstream" read-tree -mu HEAD 